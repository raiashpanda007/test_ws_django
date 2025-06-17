import os
import asyncio
import aiofiles
from channels.generic.websocket import AsyncWebsocketConsumer
from watchdog.observers import Observer
from watchdog.events import FileSystemEventHandler

LOG_FILE_PATH = 'test_logs.txt'
MAX_LINES = 10
CHUNK_SIZE = 1024


class LogConsumer(AsyncWebsocketConsumer):
    async def connect(self):
        await self.accept()
        await self.send_last_lines()

        log_directory = os.path.dirname(os.path.abspath(LOG_FILE_PATH))
        self.loop = asyncio.get_event_loop()
        self.log_observer = LogObserver(self, self.loop)
        self.log_observer.start(log_directory)

    async def disconnect(self, close_code):
        if hasattr(self, 'log_observer'):
            self.log_observer.stop()

    async def send_last_lines(self):
        try:
            last_lines = await self.get_last_n_lines(MAX_LINES)
            await self.send(text_data=last_lines)
        except Exception as e:
            await self.send(text_data=f"Error Reading log File : {str(e)}")

    async def get_last_n_lines(self, n):
        async with aiofiles.open(LOG_FILE_PATH, 'rb') as log_file:
            await log_file.seek(0, os.SEEK_END)
            position = await log_file.tell()
            buffer = bytearray()
            lines = []
            lines_found = 0

            while position > 0 and lines_found < n:
                read_size = min(CHUNK_SIZE, position)
                await log_file.seek(position - read_size, os.SEEK_SET)
                chunk = await log_file.read(read_size)
                buffer[:0] = chunk
                position -= read_size

                try:
                    lines = buffer.decode('utf-8', errors='ignore').splitlines(keepends=True)
                except UnicodeDecodeError:
                    continue

                lines_found = len(lines)

            return ''.join(lines[-n:])


class LogObserver:
    def __init__(self, consumer, loop):
        self.consumer = consumer
        self.observer = Observer()
        self.loop = loop

    def start(self, log_directory):
        event_handler = LogFileHandler(self.consumer, self.loop)
        self.observer.schedule(event_handler, path=log_directory, recursive=False)
        self.observer.start()

    def stop(self):
        if self.observer.is_alive():
            self.observer.stop()
            self.observer.join()


class LogFileHandler(FileSystemEventHandler):
    def __init__(self, consumer, loop):
        self.consumer = consumer
        self.loop = loop

    def on_modified(self, event):
        if event.src_path == os.path.abspath(LOG_FILE_PATH):
            self.loop.call_soon_threadsafe(asyncio.create_task, self.consumer.send_last_lines())

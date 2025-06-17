from django.shortcuts import render

def log_view(request):
    return render(request, 'log_app/index.html')

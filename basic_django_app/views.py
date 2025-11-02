from django.shortcuts import render

def home(request):
    return render(request, "home.html", {"message": "Hi, My name is Vipul Warthe"})

import os
import django

os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'config.settings')
django.setup()

from django.contrib.auth.models import User

if not User.objects.exists():
    User.objects.create_superuser('admin', 'admin@example.com', 'Botela@0308')
    print('Superuser "admin" created.')
else:
    print(f'User "{User.objects.first().username}" already exists.')

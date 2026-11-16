from django.contrib import admin
from django.urls import path, include
from django.conf import settings
from django.conf.urls.static import static

urlpatterns = [
    path('admin/', admin.site.urls),
    path('', include('sarpras.urls')),
]

# ==========================
# MEDIA FILES
# ==========================
if settings.DEBUG:
    urlpatterns += static(settings.MEDIA_URL, document_root=settings.MEDIA_ROOT)

# ===============================
# SETTING MEDIA FILE
# ===============================
# agar file gambar (ImageField) bisa diakses di browser
# HANYA aktif saat DEBUG = True
if settings.DEBUG:
    urlpatterns += static(
        settings.MEDIA_URL,
        document_root=settings.MEDIA_ROOT
    )





from django.contrib import admin
from django.utils.html import format_html

# import model satu per satu (aman & jelas)
from .models import (
    Tanah,   
    Jalan,
    Buku,       
    BarangHabisPakai,
    BarangHabisPakaiMasuk,
    BarangHabisPakaiKeluar
              
)


#==================================================================
# habis pakai disisni
#==================================================================

@admin.register(BarangHabisPakai)
class BarangHabisPakaiAdmin(admin.ModelAdmin):
    list_display = ('kode_barang', 'nama_barang', 'stok', 'satuan')
    search_fields = ('kode_barang', 'nama_barang')


@admin.register(BarangHabisPakaiMasuk)
class BarangMasukAdmin(admin.ModelAdmin):
    list_display = ('barang', 'jumlah', 'tanggal', 'sumber')
    list_filter = ('tanggal', 'sumber')


@admin.register(BarangHabisPakaiKeluar)
class BarangKeluarAdmin(admin.ModelAdmin):
    list_display = ('barang', 'jumlah', 'tanggal', 'pengguna', 'keperluan')
    list_filter = ('tanggal', 'pengguna')

# =====================================================
# MODEL LAIN (REGISTRASI SIMPEL, TIDAK DIUBAH)
# =====================================================
admin.site.register(Tanah)
admin.site.register(Jalan)
admin.site.register(Buku)


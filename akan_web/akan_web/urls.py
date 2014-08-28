from django.conf.urls import patterns, include, url
from webservice import views
from django.contrib import admin
admin.autodiscover()

urlpatterns = patterns('',
    # Examples:
    # url(r'^$', 'akan_web.views.home', name='home'),
    # url(r'^blog/', include('blog.urls')),

    # url(r'^admin/', include(admin.site.urls)),
    url(r'^parlamentar/$', views.get_all_parliamentaries),
    url(r'^parlamentar/(?P<parliamentary_id>\d{1,10})/$', views.get_parliamentary),
    url(r'^cota/$', views.get_all_quotas),
    url(r'^cota/parlamentar/(?P<parliamentary_id>\d{1,10})/$', views.get_quotas_for_parliamentary),
    url(r'^versao/$', views.get_data_version),
    url(r'^cota/media-maximo-por-periodo$', views.get_quotas_average_max_by_period),
    url(r'^cota/media-maximo-desvio$', views.get_quotas_average_max_std_deviation),
)

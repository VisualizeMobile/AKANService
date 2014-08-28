from django.shortcuts import render
from django.http import HttpResponse
from django.core import serializers
from models import *
from django.db.models import *
import json
import util
# Create your views here.

def get_all_parliamentaries(request):
    all_parliamentaries = Parlamentar.objects.all().order_by('ranking')
    json_response = serializers.serialize('json', all_parliamentaries)
    
    return HttpResponse(json_response, mimetype='application/json')

def get_all_quotas(request):
    all_quotas = Cota.objects.all()
    json_response = serializers.serialize('json', all_quotas)
    
    return HttpResponse(json_response, mimetype='application/json')

def get_quotas_for_parliamentary(request, parliamentary_id):
    quotas_for_parliamentary = Cota.objects.filter(idparlamentar=parliamentary_id)
    json_response = serializers.serialize('json', quotas_for_parliamentary)
    
    return HttpResponse(json_response, mimetype='application/json')

def get_parliamentary(request, parliamentary_id):
	parliamentary = Parlamentar.objects.get(pk=parliamentary_id)
	json_response = serializers.serialize('json', [parliamentary])

	return HttpResponse(json_response[1:-1], mimetype='application/json')

def get_data_version(request):
	version = VersaoDados.objects.all()
	json_response = serializers.serialize('json', version)

	return HttpResponse(json_response, mimetype='application/json')

def get_quotas_average_max_by_period(request):
    quotas_avg_and_max_by_period = Cota.objects.values('numsubcota', 'ano', 'mes').annotate(valor_medio=Avg('valor'), valor_maximo=Max('valor')).order_by('numsubcota', 'ano', 'mes')
    json_response = json.dumps(list(quotas_avg_and_max_by_period), cls=util.DecimalEncoder)

    return HttpResponse(json_response, mimetype='application/json')

def get_quotas_average_max_std_deviation(request):
    quotas_average_max_std = Cota.objects.values('numsubcota').annotate(valor_medio=Avg('valor'), valor_maximo=Max('valor'), desvio_padrao=StdDev('valor')).order_by('numsubcota')
    json_response = json.dumps(list(quotas_average_max_std), cls=util.DecimalEncoder)

    return HttpResponse(json_response, mimetype='application/json')
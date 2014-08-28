# This is an auto-generated Django model module.
# You'll have to do the following manually to clean this up:
#   * Rearrange models' order
#   * Make sure each model has one field with primary_key=True
#   * Remove `managed = False` lines if you wish to allow Django to create and delete the table
# Feel free to rename the models, but don't rename db_table values or field names.
#
# Also note: You'll have to insert the output of 'django-admin.py sqlcustom [appname]'
# into your database.
from __future__ import unicode_literals

from django.db import models

class Cota(models.Model):
    idcota = models.BigIntegerField(db_column='idCota', primary_key=True) # Field name made lowercase.
    idparlamentar = models.ForeignKey('Parlamentar', db_column='idParlamentar') # Field name made lowercase.
    mes = models.IntegerField(blank=True, null=True)
    ano = models.IntegerField(blank=True, null=True)
    numsubcota = models.IntegerField(db_column='numSubcota', blank=True, null=True) # Field name made lowercase.
    descricao = models.CharField(max_length=100, blank=True)
    valor = models.DecimalField(max_digits=13, decimal_places=2, blank=True, null=True)
    versaoupdate = models.IntegerField(db_column='versaoUpdate', blank=True, null=True) # Field name made lowercase.

    def __unicode__(self):
        return '{0} ({1})'.format(self.idcota, self.valor)

    class Meta:
        managed = False
        db_table = 'cota'

class Parlamentar(models.Model):
    idparlamentar = models.IntegerField(db_column='idParlamentar', primary_key=True) # Field name made lowercase.
    nomeparlamentar = models.CharField(db_column='nomeParlamentar', max_length=100) # Field name made lowercase.
    partidoparlamentar = models.CharField(db_column='partidoParlamentar', max_length=45, blank=True) # Field name made lowercase.
    ufparlamentar = models.CharField(db_column='ufParlamentar', max_length=45) # Field name made lowercase.
    valor = models.DecimalField(max_digits=13, decimal_places=2, blank=True, null=True)
    ranking = models.IntegerField(blank=True, null=True)

    def __unicode__(self):
        return '{0} ({1})'.format(self.idparlamentar, self.nomeparlamentar)

    class Meta:
        managed = False
        db_table = 'parlamentar'

class Despesa(models.Model):
    txnomeparlamentar = models.CharField(db_column='txNomeParlamentar', max_length=100, blank=True) # Field name made lowercase.
    nucarteiraparlamentar = models.IntegerField(db_column='nuCarteiraParlamentar', blank=True, null=True) # Field name made lowercase.
    nulegislatura = models.IntegerField(db_column='nuLegislatura', blank=True, null=True) # Field name made lowercase.
    sguf = models.CharField(db_column='sgUF', max_length=45, blank=True) # Field name made lowercase.
    sgpartido = models.CharField(db_column='sgPartido', max_length=45, blank=True) # Field name made lowercase.
    codlegislatura = models.IntegerField(db_column='codLegislatura', blank=True, null=True) # Field name made lowercase.
    numsubcota = models.IntegerField(db_column='numSubCota', blank=True, null=True) # Field name made lowercase.
    txtdescricao = models.CharField(db_column='txtDescricao', max_length=100, blank=True) # Field name made lowercase.
    numespecificacaosubcota = models.IntegerField(db_column='numEspecificacaoSubCota', blank=True, null=True) # Field name made lowercase.
    txtdescricaoespecificacao = models.CharField(db_column='txtDescricaoEspecificacao', max_length=100, blank=True) # Field name made lowercase.
    txtbeneficiario = models.CharField(db_column='txtBeneficiario', max_length=100, blank=True) # Field name made lowercase.
    txtcnpjcpf = models.CharField(db_column='txtCNPJCPF', max_length=45, blank=True) # Field name made lowercase.
    txtnumero = models.IntegerField(db_column='txtNumero', blank=True, null=True) # Field name made lowercase.
    indtipodocumento = models.IntegerField(db_column='indTipoDocumento', blank=True, null=True) # Field name made lowercase.
    datemissao = models.DateTimeField(db_column='datEmissao', blank=True, null=True) # Field name made lowercase.
    vlrdocumento = models.DecimalField(db_column='vlrDocumento', max_digits=13, decimal_places=2, blank=True, null=True) # Field name made lowercase.
    vlrglosa = models.DecimalField(db_column='vlrGlosa', max_digits=13, decimal_places=2, blank=True, null=True) # Field name made lowercase.
    vlrliquido = models.DecimalField(db_column='vlrLiquido', max_digits=13, decimal_places=2, blank=True, null=True) # Field name made lowercase.
    nummes = models.IntegerField(db_column='numMes', blank=True, null=True) # Field name made lowercase.
    numano = models.IntegerField(db_column='numAno', blank=True, null=True) # Field name made lowercase.
    numparcela = models.IntegerField(db_column='numParcela', blank=True, null=True) # Field name made lowercase.
    numlote = models.IntegerField(db_column='numLote', blank=True, null=True) # Field name made lowercase.
    numressarcimento = models.IntegerField(db_column='numRessarcimento', blank=True, null=True) # Field name made lowercase.
    idecadastro = models.IntegerField(db_column='ideCadastro', blank=True, null=True) # Field name made lowercase.
    iddespesa = models.IntegerField(db_column='idDespesa', primary_key=True) # Field name made lowercase.
    class Meta:
        managed = False
        db_table = 'despesa'

class VersaoDados(models.Model):
    id = models.IntegerField(primary_key=True)
    versaoupdate = models.BigIntegerField(db_column='versaoUpdate') # Field name made lowercase.

    def __unicode__(self):
        return str(versaoUpdate)
    
    class Meta:
        managed = False
        db_table = 'versao_dados'
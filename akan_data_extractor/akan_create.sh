#!/bin/bash

DB_USER=$1
DB_PASS=$2
DATA_DIR=$3
[[ ! "$DATA_DIR" ]] && DATA_DIR="$HOME"
WORK_DIR="$DATA_DIR/akan_files"
THIS_SCRIPT_PATH="$(dirname $0)"
FILES_LIST="AnoAtual AnoAnterior AnosAnteriores"

function prepare_enviroment {
	[[ ! -d "$WORK_DIR/" ]] && mkdir $WORK_DIR/
	rm -f $WORK_DIR/*

	for FILE in $FILES_LIST
	do
		echo -e "\n >>>> Downloading data (File $FILE)\n"
		wget -P $WORK_DIR/ http://www.camara.gov.br/cotas/$FILE.zip	
		if [[ ! -f "$WORK_DIR/$FILE.zip" ]]
		then
			echo "ERROR: File $WORK_DIR/$FILE.zip don't exist"
			exit -1
		fi
	done

	echo -e "\n >>>> Unziping data\n"
	unzip -o -d $WORK_DIR $WORK_DIR/\*.zip


	for FILE in $FILES_LIST
	do
		echo -e "\n >>>> Converting XML from UTF-16 to UTF-8 (File $FILE)\n"
		iconv -f UTF-16 -t UTF-8 $WORK_DIR/$FILE.xml > $WORK_DIR/$FILE.xml.bak
		mv -f $WORK_DIR/$FILE.xml.bak $WORK_DIR/$FILE.xml
		perl -pi -e '!$x && s/utf-16/utf-8/ && ($x=1)' $WORK_DIR/$FILE.xml

		if [[ "$?" -ne "0" ]]
		then
			exit -1
		fi
	done
}

function prepare_db {
	if [[ ! -f "$THIS_SCRIPT_PATH/akan_schema.sql" ]]
	then
		echo "ERROR: File $THIS_SCRIPT_PATH/akan_schema.sql don't exist"
		exit -1
	fi

	QUERY="CREATE DATABASE IF NOT EXISTS akan CHARACTER SET utf8 COLLATE utf8_general_ci;"

	echo -e "\n >>>> Creating database if not exists\n"
	mysql -u $DB_USER --password=$DB_PASS -e "$QUERY"
	if [[ "$?" -ne "0" ]]
	then
		exit -1
	fi

	echo -e "\n >>>> Loading database schema\n"
	mysql -u $DB_USER --password=$DB_PASS akan < $THIS_SCRIPT_PATH/akan_schema.sql

	if [[ "$?" -ne "0" ]]
	then
		exit -1
	fi

	QUERY="CALL InicializaTabelaVersaoDados();"

	echo -e "\n >>>> Initializing data version\n"
	mysql -u $DB_USER --password=$DB_PASS akan -e "$QUERY"
	if [[ "$?" -ne "0" ]]
	then
		exit -1
	fi
}

function load_despesa_table {

	for FILE in $FILES_LIST
	do
		QUERY="LOAD DATA LOCAL INFILE '$WORK_DIR/$FILE.xml'
	    INTO TABLE despesa 
	    CHARACTER SET utf8 
	    LINES STARTING BY '<DESPESA>' TERMINATED BY '</DESPESA>'
	        (@despesa)
	    SET  
	        txNomeParlamentar = ExtractValue(@despesa, 'txNomeParlamentar'),
	        ideCadastro = ExtractValue(@despesa, 'ideCadastro'),
	        nuCarteiraParlamentar = ExtractValue(@despesa, 'nuCarteiraParlamentar'),
	        nuLegislatura = ExtractValue(@despesa, 'nuLegislatura'),
	        sgUF = ExtractValue(@despesa, 'sgUF'),
	        sgPartido = ExtractValue(@despesa, 'sgPartido'),
	        codLegislatura = ExtractValue(@despesa, 'codLegislatura'),
	        numSubCota = ExtractValue(@despesa, 'numSubCota'),
	        txtDescricao = ExtractValue(@despesa, 'txtDescricao'),
	        numEspecificacaoSubCota = ExtractValue(@despesa, 'numEspecificacaoSubCota'),
	        txtDescricaoEspecificacao = ExtractValue(@despesa, 'txtDescricaoEspecificacao'),
	        txtBeneficiario = ExtractValue(@despesa, 'txtBeneficiario'),
	        txtCNPJCPF=ExtractValue(@despesa, 'txtCNPJCPF'),
	        txtNumero = ExtractValue(@despesa, 'txtNumero'),
	        indTipoDocumento = ExtractValue(@despesa, 'indTipoDocumento'),
	        datEmissao = ExtractValue(@despesa, 'datEmissao'),
	        vlrDocumento = ExtractValue(@despesa, 'vlrDocumento'),
	        vlrGlosa = ExtractValue(@despesa, 'vlrGlosa'),
	        vlrLiquido = ExtractValue(@despesa, 'vlrLiquido'),
	        numMes = ExtractValue(@despesa, 'numMes'),
	        numAno = ExtractValue(@despesa, 'numAno'),
	        numParcela = ExtractValue(@despesa, 'numParcela'),
	        numLote = ExtractValue(@despesa, 'numLote'),
	        numRessarcimento = ExtractValue(@despesa, 'numRessarcimento')
	    "

	    echo -e "\n >>>> Loading 'despesa' table (File $FILE)\n"
		mysql --local-infile -u $DB_USER --password=$DB_PASS akan -e "$QUERY"
		if [[ "$?" -ne "0" ]]
		then
			exit -1
		fi
	done
}
function load_parlamentar_table {
	QUERY="CALL CarregaTabelaParlamentar();"

	echo -e "\n >>>> Loading 'parlamentar' table\n"
	mysql -u $DB_USER --password=$DB_PASS akan -e "$QUERY"
	if [[ "$?" -ne "0" ]]
	then
		exit -1
	fi
}

function load_cota_table {
	QUERY="CALL CarregaTabelaCota();"

	echo -e "\n >>>> Loading 'cota' table\n"
	mysql -u $DB_USER --password=$DB_PASS akan -e "$QUERY"
	if [[ "$?" -ne "0" ]]
	then
		exit -1
	fi
}

function main {
	if [[ ! "$DB_PASS" || ! "$DB_USER" ]]
	then
		echo -e "Usage:\n\t$0 <DB_USER> <DB_PASS> <DATA_DIR>\n\t$0 <DB_USER> <DB_PASS>"
		exit -1
	fi

	prepare_enviroment
	prepare_db 
	load_despesa_table
	load_parlamentar_table
	load_cota_table

	echo -e "\n >>>> Finish\n"
}

main
exit 0
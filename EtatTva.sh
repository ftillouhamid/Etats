#!/bin/bash
#
function old() {
        _DATE=`echo $_DATA | cut -d "|" -f 1 -`
        _ANNEE=`echo $_DATA | cut -d "|" -f 2 -`
        _PERIODE=`echo $_DATA | cut -d "|" -f 3 -`
        _REGIME=`echo $_DATA | cut -d "|" -f 4 -`
        _ETAT_FILE=`echo $_DATA | cut -d "|" -f 5 -`
        _XML_FILE=`echo $_DATA | cut -d "|" -f 6 -`
        _MAE_FILE=`echo $_DATA | cut -d "|" -f 7 -`
        _FLGS_HOW=`echo $_DATA | cut -d "|" -f 8 -`
        _FLG_SILENCE=`echo $_DATA | cut -d "|" -f 9 -`
        _COMMENT=`echo $_DATA | cut -d "|" -f 10 -`
}
_DATA=$(yad --title="Unimatel Etat TVA" \
--text-align="center" \
--text="<span foreground='blue'><b><big>Génère XML à partir de l\'état</big></b></span>" \
--window-icon="gtk-dnd-multiple" \
--width="600" --height="400" \
--borders=10 \
--form  --field="<b>Identifiant Fiscal</b>" \
	--field="<b>Date</b>::DT" --date-format=%d/%m/%Y \
        --field="<b>Année</b>" \
	--field="<b>Période</b>:CB" \
        --field="<b>Régime</b>:CB" \
	--field="<b>Fichier Etat</b>:FL" --filter="Etats|*.txt" \
	--field="<b>Fichier XML Résultat</b>:SFL" --file-filter="XML|*.xml" \
	--field="<b>Fichier Comptable</b>:FL" --file-filter="Comptables|*.MAE" \
	--field="Afficher dans le navigateur:CHK" \
	--field="Mode Silencieux:CHK" \
        --field="<b>Commentaire</b>::TXT" \
	"05300960" \
        "24/04/2019" \
        "2019" \
        "1!2!3!4!5!6!7!8!9!10!11!12" \
        "Mensuel!Trimestriel" \
        "TVA_TEST.txt" \
        "TVA_TEST.xml" \
	"/home/hamid/Bureau/UNIMATEL2019.MAE" \
        FALSE \
        TRUE \
        "Commentaire" \
        --button="Unimatel:2" \
        --button="gtk-ok:0" \
        --button="gtk-cancel:1" 
)
#echo $?
#echo -e "$_DATA" 
IFS="|" read -ra _FIELDS  <<< "${_DATA}";

 _TYPE="CHG"
 _TAXE="20"
 _IF=${_FIELDS[0]}
 _DATE=${_FIELDS[1]}
 _ANNEE=${_FIELDS[2]}
 _PERIODE=${_FIELDS[3]}
 _REGIME=${_FIELDS[4]}
 _ETAT_FILE=${_FIELDS[5]}
 _XML_FILE=${_FIELDS[6]}
 _MAE_FILE=${_FIELDS[7]}
 _FLGS_HOW=${_FIELDS[8]}
 _FLG_SILENCE=${_FIELDS[9]}
 _COMMENT=${_FIELDS[10]}

#echo -e  $_DATE '\n' $_ANNEE '\n' $_PERIODE '\n' $_REGIME '\n' $_ETAT_FILE '\n' $_XML_FILE '\n' $_MAE_FILE 
#echo -e  $_FLGS_HOW '\n' $_FLG_SILENCE '\n' $_COMMENT;

echo -e "php getEtat2.php" ${_ETAT_FILE}  ${_PERIODE} ${_ANNEE} ${_IF} ${_REGIME} ">"${_XML_FILE} 
php getEtat2.php  ${_ETAT_FILE}  ${_PERIODE}  ${_ANNEE} ${_IF} ${_REGIME} >${_XML_FILE}
exit


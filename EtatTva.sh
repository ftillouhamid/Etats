#!/usr/bin/env bash
#
on_click () {
	_ETAT_FILE=$1; 	#${_FIELDS[5]}
	_PERIODE=$2;	#${_FIELDS[3]}
	_ANNEE=$3;	#${_FIELDS[2]}
	_IF=$4;		#${_FIELDS[0]}
	_REGIME=$5;	#${_FIELDS[4]}
	_XML_FILE=$6;	#${_FIELDS[6]}

	_CMD=`php getEtat2.php ${_ETAT_FILE}  ${_PERIODE} ${_ANNEE} ${_IF} ${_REGIME} ">"${_XML_FILE} `
	yad --title="Traitement en cours..." \
            --form --field=":TXT" "$_CMD" --no-buttons --geometry=550x350+500+0

}
export -f on_click

help () {
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

echo -e  $_DATE '\n' $_ANNEE '\n' $_PERIODE '\n' $_REGIME '\n' $_ETAT_FILE '\n' $_XML_FILE '\n' $_MAE_FILE 
echo -e "php getEtat2.php" ${_ETAT_FILE}  ${_PERIODE} ${_ANNEE} ${_IF} ${_REGIME} ">"${_XML_FILE} 
#	 _DATE=${_FIELDS[1]}
#	 _MAE_FILE=${_FIELDS[7]}
#	 _FLGS_HOW=${_FIELDS[8]}
#	 _FLG_SILENCE=${_FIELDS[9]}
#	 _COMMENT=${_FIELDS[10]}
}
export -f help
########################################################################################################
function main() {
# Essayer de deviner la période
_NOW=`date +%d/%m/%Y`;
_DEF_ANNEE=`date +%Y`;

(( (_DEF_PERIODE=`date +%m`-1) % 12 ))

if [[ "${_DEF_PERIODE}" -eq 0 ]]; then 
	(( _DEF_PERIODE=12 ));
	(( _DEF_ANNEE-- ));
fi
#

_DATA=$(yad --title="Unimatel Etat TVA" \
--text-align="center" \
--text="<span foreground='blue'><b><big>Génère XML à partir de l\'état</big></b></span>" \
--window-icon="gtk-dnd-multiple" \
--width="600" --height="400" \
--borders=10 \
--form  \
--field="<b>Identifiant Fiscal</b>" "05300960" \
--field="<b>Date</b>::DT" --date-format=%d/%m/%Y "${_NOW}" \
--field="<b>Année</b>::NUM" "${_DEF_ANNEE}!1970..3000!1!0"  \
--field="<b>Période</b>::NUM" "${_DEF_PERIODE}!1..12!1!0" \
--field="<b>Régime</b>:CB" "Mensuel!Trimestriel" \
--field="<b>Fichier Etat</b>:FL" --filter="Etats|*.txt" "TVA_TEST.txt" \
--field="<b>Fichier XML Résultat</b>:SFL" --file-filter="XML|*.xml" \
		--confirm-overwrite="Le fichier existe l\'ecraser ?" "TVA_TEST.xml" \
--field="<b>Fichier Comptable</b>:FL" --file-filter="Comptables|*.MAE" "/home/hamid/Bureau/UNIMATEL2019.MAE" \
--field="Afficher dans le navigateur:CHK" FALSE \
--field="Mode Silencieux:CHK" TRUE \
--field="<b>Commentaire</b>::TXT"  "Commentaire" \
--field="Find!gtk-find:BTN" 'bash -c "on_click %6 %4 %3 %1 %5 %7"' \
--field="Go!gtk-ok:BTN" 'bash -c "on_click %6 %4 %3 %1 %5 %7"' \
--field="Quit!gtk-cancel:BTN" 'bash -c "on_click %6 %4 %3 %1 %5 %7"' \
--list --column=List --column="Mensuel:RD" TRUE --column="Trimestriel:RD" FALSE\
--button=gtk-ok:'bash -c "on_click %6 %4 %3 %1 %5 %7"' \
--button=gtk-help:'bash -c "help %6 %4 %3 %1 %5 %7"' \
--button=gtk-cancel:1 \
--button=gtk-quit:0 
)
#---column=2 
}
#####################################################################
main "$@"
exit
######################################################################
#--field=LABEL[:TYPE]
# Add field to form. Type may be H, RO, NUM, CHK, CB, CBE, CE, FL, SFL, DIR, CDIR, FN, MFL, MDIR, DT, SCL, CLR, # BTN, FBTN, LBL or TXT. 
# NUM - field is a numeric. Initial value format for this field is VALUE[!RANGE[!STEP![PREC]]], 
# where RANGE must be in form MIN..MAX. `!' is a default item separator. PREC is a precision for decimals. 

#echo $?
#echo -e "$_DATA" 
#echo -e  $_FLGS_HOW '\n' $_FLG_SILENCE '\n' $_COMMENT;
#php getEtat2.php  ${_ETAT_FILE}  ${_PERIODE}  ${_ANNEE} ${_IF} ${_REGIME} >${_XML_FILE}



#!/usr/bin/env bash
#Date: 25/04/2019
#Auteur: Hamid Ftillou
#Sujet: Generation d'un Xml à partir d'un Etat Comptable SAARI.
#Derinière màj: 30/04/2019
#######################################################################################################
on_click () {
	_ETAT_FILE=$1; 
	_PERIODE=$2;	
	_ANNEE=$3;	
	_IF=$4;		
	_REGIME=$5;	
	_XML_FILE=$6;	
	#echo  "php getEtat2.php" ${_ETAT_FILE}  ${_PERIODE} ${_ANNEE} ${_IF} ${_REGIME} ">"${_XML_FILE} ;
	_CMD=`php getEtat2.php ${_ETAT_FILE}  ${_PERIODE} ${_ANNEE} ${_IF} ${_REGIME} ">"${_XML_FILE} `
	yad --title="Traitement en cours..." \
            --form --field=":TXT" "$_CMD" --no-buttons --geometry=550x350+500+0

}
export -f on_click
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
	--field="<b>Fichier Etat</b>:FL" --filter="Etats|*.txt" "../Zenity/TVA_TEST.txt" \
	--field="<b>Fichier XML Résultat</b>:SFL" --file-filter="XML|*.xml" \
			--confirm-overwrite="Le fichier existe l\'ecraser ?" "../Zenity/TVA_TEST.xml" \
	--field="<b>Fichier Comptable</b>:FL" --file-filter="Comptables|*.MAE" \
		"/home/hamid/Bureau/UNIMATEL2019.MAE" \
	--field="Afficher dans le navigateur:CHK" FALSE \
	--field="Mode Silencieux:CHK" TRUE \
	--field="<b>Commentaire</b>::TXT"  "Commentaire" \
	--button=" Go ":'bash -c "on_click %6 %4 %3 %1 %5 %7"' \
	--button=gtk-ok:0 \
	--button=gtk-cancel:1 \
	--button=gtk-quit:2 
	
)
	if [ "$?" -ne 0 ]; then
		  #On quitte le script
		  exit
	fi
	IFS="|" read -ra _FIELDS  <<< "${_DATA}";
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
	 on_click  ${_ETAT_FILE}  ${_PERIODE} ${_ANNEE} ${_IF} ${_REGIME} ${_XML_FILE} ;
}
#####################################################################
main "$@"
exit
######################################################################


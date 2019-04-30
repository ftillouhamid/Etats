#!/usr/bin/php
<?php
//php php getEtat2.php /home/hamid/dev/Zenity/TVA_TEST.txt 1 2019 05300960 Mensuel > TVA_TEST.xml
$_EOL='\n';
$_USAGE ="Usage ".$argv[0]."  <fichier_etat.txt> <periode> <annee> <identifiant fiscal> <regime>\n";

if(!isset($argv[1])) {
  fwrite(STDERR,"$_USAGE");
  exit;
}

$_ETAT_FILE = $argv[1];
if (!file_exists($_ETAT_FILE)) {
  fwrite(STDERR,("fichier Etat $_ETAT_FILE fichier non trouve." . $_EOL));
  exit;
}
fwrite(STDERR,$_ETAT_FILE);
if(!isset($argv[2])) {
  fwrite(STDERR, ("Erreur PERIODE \n".$_USAGE.$_EOL));
  exit;
}
$_PERIODE= $argv[2] ;
fwrite(STDERR,$_PERIODE.$_EOL);
if(!isset($argv[3])) {
  fwrite(STDERR,"Erreur ANNEE:",$argv[3]. $_EOL.$_USAGE.$_EOL);
  exit;
}
$_ANNEE  = $argv[3] ;
fwrite(STDERR,$_ANNEE.$_EOL);
if(!isset($argv[4])) {
  fwrite(STDERR, "Erreur IF:".$argv[4].$_EOL.$_USAGE.$_EOL);
  exit;
}
$_IF=$argv[4];
fwrite(STDERR,$_IF.$_EOL);
if(!isset($argv[5])) {
  fwrite(STDERR, ("Erreur Regime\n".$_USAGE.$_EOL));
  exit;
}
$_REGIME="2";
if($_REGIME==="Mensuel")  {
  $_REGIME="1";
} 
fwrite(STDERR,$_REGIME.$_EOL);

$_ENTETE="<?xml version = \"1.0\" encoding=\"UTF-8\" standalone=\"yes\" ?>\n<DeclarationReleveDeduction>\n\t<identifiantFiscal>".$_IF."</identifiantFiscal>\n\t<annee>".$_ANNEE."</annee>\n\t<periode>".$_PERIODE."</periode>\n\t<regime>".$_REGIME."</regime>\n\t<releveDeductions>\n";  
$_BAS   ="\t</releveDeductions>\n</DeclarationReleveDeduction>";

$_TAXE	    = "20.00";
$_FRS       = array();
$_XML_FRS   = array();
$_MP_TAB    = array("ESP"=>1,"CHQ"=>2,"PRE"=>3,"VIR"=>4,"EFF"=>5,"COM"=>6,"AUT"=>7);
$_TT_TAB    = array("347551"=>"20.00","347552"=>"20.00","347553"=>"14.00","347558"=>"10.00","347554"=>"7.00","44111"=>"20.00");
$_COUNT     =0;
###################################################################
function fdate($d) {
  // convert string date from  jjmmaa to 20aa-mm-jj
  return "20".substr($d,4,2)."-".substr($d,2,2)."-".substr($d,0,2);
}
//-----------------------------------------------------------------
function modepay($mode) {
  global $_MP_TAB;
  // 1: ESP 2:CHQ 3:PRELEV 4:VIR 5: EFFET 6:COMPENS 7:AUTRE
  if( $mode ) 
	return $_MP_TAB[$mode];
  else
	return 7;
}
//-----------------------------------------------------------------
function str2num($s)  {
 // convert string like "125,4276"  to  float 125.43
  $a=str_replace(",",".",$s);
 return   round((float) $a ,2);
}
//-----------------------------------------------------------------
function tauxtaxe($CPTGEN) {
  global $_TT_TAB ;
  //"347551"=>"20.00","347552"=>"20.00","347553"=>"14.00","347558"=>"10.00","347554"=>"7.00";
  if( $CPTGEN ) 
	  return $_TT_TAB [$CPTGEN];
  else
	  return "20.00";
}
//-----------------------------------------------------------------
function print_frs_tab() {

  global $_FRS;
  $_COUNT=0;
  foreach($_FRS as $_CODE => $_FLD) {
	printf("%-4s %-25s %15s %9s %10s\n",
			$_CODE,
			$_FLD["NOM"],
			$_FLD["ICE"],
			$_FLD["IF"],
			$_FLD["DES"]
	    );
	$_COUNT++;
  }
  printf("------------------------------------\n");
  printf("%d enregistrements trouves\n", $_COUNT) ;
}
//-------------------------------------------------------------------
function readFrs($_FILE) {
   global $_FRS;
   global $_XML_FRS;
   global $_COUNT;
   $_COUNT=0;
   $_LINE="";
   $_BUFFER = file("$_FILE",FILE_IGNORE_NEW_LINES);
   foreach($_BUFFER as $_LINE_NUM =>$_LINE ) {
      if($_LINE !== "#MPCT") continue;
      $_COUNT++;
      $_CODE =$_BUFFER[$_LINE_NUM+1];     
      $_FRS["$_CODE"] = array(  "NOM" => $_BUFFER[$_LINE_NUM+2],
				"DES" => $_BUFFER[$_LINE_NUM+5],
				"ICE" => $_BUFFER[$_LINE_NUM+9],
				"IF"  => $_BUFFER[$_LINE_NUM+37]
			     );
      $_XML_FRS["$_CODE"]="<refF>\n".
                              "\t\t\t\t<if>".$_FRS[$_CODE]["IF"]."</if>\n".
                              "\t\t\t\t<nom>".$_FRS[$_CODE]["NOM"]."</nom>\n".
                              "\t\t\t\t<ice>".$_FRS[$_CODE]["ICE"]."</ice>\n".
                    "\t\t\t</refF>\n";
   }   
}
//------------------------------------------------------------------------------
function readEtat($_FILE) {
   global $_FRS, $_TAXE, $_XML_FRS, $_ENTETE,$_BAS;
   global $_TOT_HT,$_TOT_TVA,$_TOT_TTC,$_TYPE;
   $_COUNT=0;
   $_LINE="";
   fwrite(STDERR, "Traitement de :".$_FILE."\n");
   $_TOT_HT=0; $_TOT_TVA=0; $_TOT_TTC=0;
   echo $_ENTETE;
   $_BUFFER = file("$_FILE",FILE_IGNORE_NEW_LINES);
   foreach($_BUFFER as $_LINE_NUM =>$_LINE ) {
     
      if($_LINE !== "#MECG") continue;
      $_COUNT++;
      $_JRN    =$_BUFFER[$_LINE_NUM+1];     
      $_DPAI   =fdate($_BUFFER[$_LINE_NUM+2]);     
      $_CPTGEN =$_BUFFER[$_LINE_NUM+7]; $_TAXE=tauxtaxe($_CPTGEN);
      $_NUM    =$_BUFFER[$_LINE_NUM+5];     
      $_TIERS  =$_BUFFER[$_LINE_NUM+9];     
      $_REG    =$_BUFFER[$_LINE_NUM+28];        ;  $_MP=modepay(substr($_REG,0,3));    
      $_HT     =str2num($_BUFFER[$_LINE_NUM+29]);  $_TOT_HT+=$_HT; 
      $_DFAC   =fdate($_BUFFER[$_LINE_NUM+31]); 

      if($_CPTGEN=="347551") {
	      $_TVA    =str2num($_BUFFER[$_LINE_NUM+30]);  
        $_TTC  =str2num($_BUFFER[$_LINE_NUM+18]); 
        $_LIBELLE=$_FRS["$_TIERS"]["DES"]; 
      } else {
	      $_TVA=str2num($_BUFFER[$_LINE_NUM+18]);
        $_TTC  =$_HT+$_TVA;   
        $_LIBELLE=str_pad(substr($_BUFFER[$_LINE_NUM+11],0,20),20," ");  
      }
	    $_TOT_TVA+=$_TVA; 
      $_TOT_TTC+=$_TTC;

      fwrite(STDERR, $_COUNT."\t".$_DFAC." \t".
      str_pad(substr($_FRS["$_TIERS"]["NOM"],0,20),20," ")."\t".
      str_pad(substr($_NUM,0,20),20," ")."\t".$_JRN."\t".
      str_pad(number_format( $_TTC, 2, ',', ' ' ), 10, ' ', STR_PAD_LEFT)."\t".
      str_pad(number_format( $_TVA, 2, ',', ' ' ), 10, ' ', STR_PAD_LEFT)."\t".
      str_pad(number_format( $_HT,  2, ',', ' ' ), 10, ' ', STR_PAD_LEFT)."\t".
      str_pad(substr($_REG,0,10),10," ")."\t".$_MP."\t".$_DPAI."\n"
      );
      $_DIFF=$_TTC-$_HT-$_TVA;
      if(abs($_DIFF) > 0.001)
          fwrite(STDERR, $_NUM."\t".$_TTC."\t".$_TVA."\t".$_HT."\t #".$_DIFF."\n");
      
      //number_format(number,decimals,decimalpoint,separator)
     echo  "\t\t<rd>\n";
     echo  "\t\t\t<ord>".$_COUNT."</ord>\n";
     echo  "\t\t\t<num>".$_NUM."</num>\n";
     echo  "\t\t\t<des>".$_LIBELLE."</des>\n";
     echo  "\t\t\t<mht>".number_format($_HT,2,'.','')."</mht>\n";
     echo  "\t\t\t<tva>".number_format($_TVA,2,'.','')."</tva>\n";
     echo  "\t\t\t<ttc>".number_format($_TTC,2,'.','')."</ttc>\n";
     echo  "\t\t\t".$_XML_FRS[$_TIERS];
     echo  "\t\t\t<tx>".$_TAXE."</tx>\n";
     echo  "\t\t\t<mp>\n\t\t\t\t<id>".$_MP."</id>\n\t\t\t</mp>\n";
     echo  "\t\t\t<dpai>".$_DPAI."</dpai>\n";
     echo  "\t\t\t<dfac>".$_DFAC."</dfac>\n";
     echo  "\t\t</rd>\n";
  }
  echo $_BAS;
  fwrite(STDERR, "\t".
                     "Totaux:\t".
                     number_format($_TOT_HT,2,'.','')."\t".
                     number_format($_TOT_TVA,2,'.','')."\t".
                     number_format($_TOT_TTC,2,'.','')."\t".
                     "\t".
                     "\t".
                     "\t".
                     "\t".
                     "\t".
                     "\t".
                     "\n"
          );
}
//readFrs($_FRS_FILE);
readFrs($_ETAT_FILE);
//print_frs_tab($_FRS);
//exit;
//  print_r($_FRS);
//echo $_ETAT_FILE;
readEtat($_ETAT_FILE);
//echo "Totaux :".number_format($_TOT_HT,2)."\t".number_format($_TOT_TVA,2)."\t".number_format($_TOT_TTC,2)."\n";
fwrite(STDERR, $_COUNT. " Factures traitess \n");
fwrite(STDERR,"Totaux : HT:".number_format($_TOT_HT,2,"."," ")."\tTVA:".number_format($_TOT_TVA,2,"."," ")."\tTTC:".number_format($_TOT_TTC,2,"."," ")."\n");
?>

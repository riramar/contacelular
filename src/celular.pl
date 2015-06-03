#!/usr/bin/perl

use HTTP::Lite;

$http = new HTTP::Lite;
$url = "http://online.telefonica.net.br/conta/ContaDetalhada/LoginSenha/EcoLgi.asp?VStrLnk=../EcoVrfRst.asp";
$req = $http->request("$url") or die "Unable to get document: $!";
$body = $http->body();
@lines = split(/^/,$body);
foreach $line (@lines)
{
	if ($line =~ /EcoVrfLgi\.asp/)
	{
		$line =~ s/^.*action=\"//g;
		$line =~ s/\".*$//g;
		$url2 = $line;
	}
}

$http2 = new HTTP::Lite;
# Altere a linha abaixo em 12341234 com seu numero de telefone e 9999 com a sua senha de acesso ao site da telefonica
%vars = ("Args" => "PF;11;12341234;;9999");
$http2->prepare_post(\%vars);
$url = "http://online.telefonica.net.br/conta/ContaDetalhada/LoginSenha/" . $url2;
$req = $http2->request("$url") or die "Unable to get document: $!";
$body = $http2->body();
@lines = split(/^/,$body);
foreach $line (@lines){
	if ($line =~ /EcoVrfRst\.asp/)
	{
		$line =~ s/^.*HREF=\"//g;
		$line =~ s/\".*$//g;
		$url2 = $line;
	}
}

$http3 = new HTTP::Lite;
$url = "http://online.telefonica.net.br/conta/ContaDetalhada/LoginSenha/" . $url2;
$req = $http3->request("$url") or die "Unable to get document: $!";
$body = $http3->body();
@lines = split(/^/,$body);
foreach $line (@lines){
	if ($line =~ /EcoSelContaDet\.asp/)
	{
		$line =~ s/^.*HREF=\"//g;
		$line =~ s/\".*$//g;
		$url2 = $line;
	}
}

$http4 = new HTTP::Lite;
$url = "http://online.telefonica.net.br/conta/ContaDetalhada/" . $url2;
$req = $http4->request("$url") or die "Unable to get document: $!";
$body = $http4->body();
@lines = split(/^/,$body);
foreach $line (@lines){
	if ($line =~ /EcoContaDet1\.asp/)
	{
		$line =~ s/^.*= \"//g;
		$line =~ s/\".*$//g;
		$url2 = $line;
	}
}
foreach $line (@lines){
	if ($line =~ />$ARGV[0] *\/$ARGV[1]</)
	{
		$pars = $line;
		$pars =~ s/^.*FAbrContaNova\(//g;
		$pars =~ s/\).*$//g;
	}
}

$http5 = new HTTP::Lite;
$pars =~ s/,/\&VValor=/g;
$url2 =~ s/\n//g;
$url = "http://online.telefonica.net.br/conta/ContaDetalhada/" . $url2 . "&VString=" . $pars;
$req = $http5->request("$url") or die "Unable to get document: $!";
$body = $http5->body();
@lines = split(/^/,$body);
foreach $line (@lines){
	if ($line =~ /EcoContaDetNova1\.asp/)
	{
		$line =~ s/^.*HREF=\"//g;
		$line =~ s/\".*$//g;
		$url2 = $line;
	}
}

$http6 = new HTTP::Lite;
$url = "http://online.telefonica.net.br/conta/ContaDetalhada/" . $url2;
$url =~ s/amp;//g;
$req = $http6->request("$url") or die "Unable to get document: $!";
$body = $http6->body();
@lines = split(/^/,$body);
foreach $line (@lines){
	if ($line =~ /<pre>/)
	{
		$conta = $line;
	}
}
foreach $linha (@lines)
{
	#print $linha . "\n";
}

$conta =~ s/^.*LIGACOES PARA CELULAR<\/p>//g;
$conta =~ s/<p> *CHAMADAS DE LONGA DISTANCIA.*$//g;
$conta =~ s/<\/p>//g;
@linhas = split(/<p>/,$conta);
foreach $linha (@linhas)
{
	#print $linha . "\n";
}

open(ARQ_TELS, "<telefones.csv");
	while(<ARQ_TELS>) {
		push(@telefones,$_);
	}
close(ARQ_TELS);

$total_daniel = 0;
$total_ricardo = 0;
$total_marco = 0;
$total_zilda = 0;
$total_iramar = 0;
$total_conhecido = 0;
$total_desconhecido = 0;

foreach $linha (@linhas)
{
						# 			DATA 		TELEFONE LOCALIDADE OPERAD. INICIO DURACAO TARIFA VALOR
						# 007 	17/02/06 95300971 AREA-011 VIVO 13H55M13 0,5 A COB NORMAL 0,33
	if ( $linha =~ /^(\d+)\s+(\S+)\s+(\d+)\s+(\S+)\s+(\w+)\s+(\S+)\s+(\S+)\s+(NORMAL|REDUZIDA|A\ COB\ NORMAL)\s+(\S+).*$/xi )
	{
		$tel_conta = $3;
		$val_conta = $9;
		
		foreach $tel (@telefones)
		{
			@descfones = split(/;/,$tel);
			$recebeu = $descfones[1];
			$ligou = $descfones[2];
			$val_conta =~ s/,/./g;

			if ( $tel =~ /$tel_conta/ )
			{
				#Telefone conhecido em telefones.csv
				print $ligou . " " . $recebeu . " " . $tel_conta . " " . $val_conta . "\n";
				$conhecido = 1;
				if ( $ligou eq "Daniel" )
				{
					$total_daniel = $total_daniel + $val_conta;
				}
				elsif ( $ligou eq "Ricardo" )
				{
					$total_ricardo = $total_ricardo + $val_conta;
				}
				elsif ( $ligou eq "Marco" )
				{
					$total_marco = $total_marco + $val_conta;
				}
				elsif ( $ligou eq "Zilda" )
				{
					$total_zilda = $total_zilda + $val_conta;
				}
				elsif ( $ligou eq "Iramar" )
				{
					$total_iramar = $total_iramar + $val_conta;
				}
				$total_conhecido = $total_conhecido + $val_conta;
			}
		}
		if ( $conhecido == 1 )
		{
			$conhecido = 0;
		}
		else
		{
			#Telefone DESconhecidos em telefones.csv
			print "DESCONHECIDO " . $tel_conta . " " . $val_conta . "\n";
			$total_desconhecido = $total_desconhecido + $val_conta;
		}
	}
}

$total = $total_conhecido + $total_desconhecido;
print "\nDaniel: $total_daniel\n";
print "Ricardo: $total_ricardo\n";
print "Marco: $total_marco\n";
print "Zilda: $total_zilda\n";
print "Iramar: $total_iramar\n";
print "Total Conhecido: $total_conhecido\n";
print "Total Desconhecido: $total_desconhecido\n";
print "Total Geral: $total\n";

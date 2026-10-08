%%% dsa5mappe.cls — Dokumentklasse fuer die Charaktermappe (bogen/mappe/).
%%%
%%%   \def\Fassung{digital}   4 x A4 hochkant (Vorgabe)
%%%   \def\Fassung{druck}     2 x A3 quer
%%%   \documentclass{dsa5mappe}
%%%
%%% Copyright 2026 Leif Janzik. Apache License 2.0, siehe LICENSE.
%%%
%%% Die Klasse laedt dsa5latex.cls und nimmt daran zurueck, was ein Umschlag
%%% nicht hat: zwei Spalten, Satzspiegel, Kopf- und Fusszeilen. Alles
%%% Uebrige kommt von dort und hat dort genau eine Quelle: die Schriften des
%%% Baukastens (Gentium Basic, Andalus), der Pflichttext, die Farben, und vor
%%% allem der Covertitel mit seinen fuenf Lagen (Flaechenschatten, Flaeche,
%%% Schriftschatten, heller Rand, Verlauf), siehe doku/ELEMENTE.md, „Der Titel
%%% auf dem Umschlag". Bis 2026-10-08 lief die Mappe auf article mit
%%% Ersatzschriften und einem selbstgebauten Kontureffekt.
%%%
%%% Was neu ist:
%%%   \dsaMappeTitelFadings{Zeilen}   vor dem Bild, ausserhalb jeder tikzpicture
%%%   \dsaMappeTitel{x}{oben}{Zeilen} im Blatt, x und Oberkante in mm
%%%   \dsaMappeTitelFarben{HEX}       Titelfarben aus der Akzentfarbe
%%% Zeilen sind eine Folge von \dsaTitelZeile[Grad]{Text}, wie beim Umschlag.

\NeedsTeXFormat{LaTeX2e}
\ProvidesClass{dsa5mappe}[2026/10/08 v1.0 DSA5 Charaktermappe]

\DeclareOption*{\PassOptionsToClass{\CurrentOption}{dsa5latex}}
\ProcessOptions\relax

% ohneraster: kein Grundlinienraster, kein \topskip-Zwang.
% ohnehintergrund: keine Buchseiten-Grafik; die Mappe zeichnet ihr
% Pergament selbst.
\LoadClass[ohneraster,ohnehintergrund]{dsa5latex}

% --- Seite -----------------------------------------------------------------
% Randabfallend, ein Blatt ist eine Box von 210 x 297 mm (bogen/mappe/
% mechanik-mappe.tex). reset nimmt Satzspiegel, twoside und Fussabstand der
% Abenteuerklasse zurueck; sonst summieren sich die Schluessel.
\ifx\Fassung\undefined \def\Fassung{digital}\fi
\def\dsa@mappe@druck{druck}
\ifx\Fassung\dsa@mappe@druck
  \geometry{reset, papersize={420mm,297mm}, margin=0pt}
\else
  \geometry{reset, papersize={210mm,297mm}, margin=0pt}
\fi
\@twosidefalse
\AtBeginDocument{\onecolumn\pagestyle{empty}\dsaHintergrundAus}

% --- Covertitel an beliebiger Stelle -----------------------------------------
% \dsaUmschlagVorne setzt den Titel von der Papierkante aus. Die Mappe braucht
% ihn oben im Blatt, gesetzt von der Oberkante nach unten, und in einer
% tikzpicture mit y nach unten (x=1mm, y=-1mm). Deshalb dieselben vier
% Zeichenstufen wie dort, nur mit eigener Koordinate.
%
% Die Fadings muessen AUSSERHALB jeder tikzpicture deklariert werden, und das
% Blatt ist eine. Daher zwei Befehle: \dsaMappeTitelFadings vor dem Blatt,
% \dsaMappeTitel darin -- beide mit derselben Zeilenliste.
\newcounter{dsa@mappe@nr}
\newlength{\dsa@mappe@y}

% \dsaTitelLuecke{mm} in der Zeilenliste: zusaetzlicher Abstand vor der
% naechsten Zeile, etwa zwischen Name und Profession. Ausserhalb der
% Zeichenstufen ohne Wirkung.
\newcommand{\dsaTitelLuecke}[1]{}

\newcommand{\dsaMappeTitelFadings}[1]{%
  \setcounter{dsa@mappe@nr}{0}%
  \renewcommand{\dsaTitelZeile}[2][\dsatitelgrad]{%
    \stepcounter{dsa@mappe@nr}%
    \edef\dsa@titelname{dsamappezeile\thedsa@mappe@nr}%
    \expandafter\pgfdeclarefading\expandafter{\dsa@titelname}{%
      \tikz\node[inner sep=1pt, text=white]
        {\dsa@titelschriftgrad{##1}##2};}}%
  #1}

% Eine Stufe ueber alle Zeilen. #1 Stufe, #2 x mm, #3 Oberkante mm, #4 Zeilen.
% Jede Zeile setzt ihre Unterkante (anchor south) um Zeilenfaktor x Grad
% unter die vorige.
\newcommand{\dsa@mappe@stufe}[4]{%
  \setcounter{dsa@mappe@nr}{0}%
  \setlength{\dsa@mappe@y}{#3mm}%
  \renewcommand{\dsaTitelLuecke}[1]{\addtolength{\dsa@mappe@y}{##1mm}}%
  \renewcommand{\dsaTitelZeile}[2][\dsatitelgrad]{%
    \stepcounter{dsa@mappe@nr}%
    \pgfmathsetlength{\dsa@titelvorschub}{\dsatitelzeilenfaktor*##1}%
    \addtolength{\dsa@mappe@y}{\dsa@titelvorschub}%
    % Fading-Name und Koordinate jetzt festhalten: \pgfdeclarefading nimmt
    % den Namen unexpandiert, und die Laenge laeuft mit der naechsten Zeile
    % weiter. Grad und Text bleiben unberuehrt.
    \edef\dsa@mappe@aufruf{\noexpand\dsa@titelzeileAn
      {dsamappezeile\thedsa@mappe@nr}{#1}{#2mm,-\the\dsa@mappe@y}%
      {\unexpanded{##1}}{\unexpanded{##2}}}%
    \dsa@mappe@aufruf}%
  #4}

% Der Klassencode rechnet mit gewoehnlichen Achsen; das Blatt hat y nach
% unten. Der scope stellt die Einheitsvektoren zurueck, die Koordinaten
% tragen ihre Einheiten selbst (mm, pt) und sind davon nicht betroffen.
\newcommand{\dsaMappeTitel}[3]{%
  \begin{scope}[x=1cm, y=1cm]
    \dsa@mappe@stufe{1}{#1}{#2}{#3}%
    \dsa@mappe@stufe{2}{#1}{#2}{#3}%
    \dsa@mappe@stufe{3}{#1}{#2}{#3}%
    \dsa@mappe@stufe{4}{#1}{#2}{#3}%
  \end{scope}}

% Titelfarben nach dem Vorbild der Verlags-Charakterboegen (Heldenbogen
% Layariel 2019): der rote Titel (\dsaTitelRot), nur im Farbton des Helden.
% Rot hat dort Schrift #B22526 nach #741C16 auf Flaeche #5F1812 mit goldener
% Kante #C08848. Uebertragen wird nur der FARBTON der Akzentfarbe; Helligkeit
% und Saettigung kommen vom Rot (HSL, gemessen: Schrift L 0,42/0,27, Flaeche
% L 0,22, S je etwa 0,67). Ein blosses Abdunkeln der Akzentfarbe gab bei der
% hellen, wenig gesaettigten Hexenfarbe #AD6ED0 einen matten, zu dunklen
% Titel. Die goldene Kante bleibt. Sechs Hexstellen, in die Praeambel: der
% Verlauf wird beim ersten Gebrauch zum PDF-Objekt (doku/ELEMENTE.md).
\newcommand{\dsaMappeTitelFarben}[1]{%
  \definecolor{dsamappeakzent}{HTML}{#1}%
  \extractcolorspecs{dsamappeakzent}{\dsa@mappe@modell}{\dsa@mappe@werte}%
  \convertcolorspec{\dsa@mappe@modell}{\dsa@mappe@werte}{Hsb}\dsa@mappe@hsb
  \expandafter\dsa@mappe@farbton\dsa@mappe@hsb\@nil
  \definecolor{dsamappetitelhell}{Hsb}{\dsa@mappe@h,0.79,0.70}%
  \definecolor{dsamappetiteldunkel}{Hsb}{\dsa@mappe@h,0.81,0.45}%
  \definecolor{dsamappetitelflaeche}{Hsb}{\dsa@mappe@h,0.81,0.37}%
  \dsaTitelSchriftfarben{dsamappetitelhell}{dsamappetiteldunkel}%
  \dsaTitelKonturfarbe{dsatitelrotkante}%
  \dsaTitelFlaechenfarbe{dsamappetitelflaeche}}
% Hsb liefert "Farbton,Saettigung,Helligkeit"; gebraucht wird nur der Farbton.
\def\dsa@mappe@farbton#1,#2,#3\@nil{\def\dsa@mappe@h{#1}}

% Wie beim Vorbild laufen die Flaechen von Name und Profession zu einem Block
% zusammen; bei 0,9 tun sie das (doku/ELEMENTE.md, \dsaTitelZeilenfaktor).
\dsaTitelZeilenfaktor{0.9}

\endinput

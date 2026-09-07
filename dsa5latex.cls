%%% dsa5latex.cls — Dokumentklasse fuer Abenteuer im Layout von
%%% Das Schwarze Auge 5, nach den Massen des offiziellen
%%% „Scriptorium Aventuris – Layout Baukastens" von Ulisses Spiele.
%%%
%%%   \documentclass{dsa5latex}
%%%
%%% Copyright 2026 Leif Janzik. Apache License 2.0, siehe LICENSE.
%%%
%%% Das Bildmaterial und die Schriften sind NICHT Teil dieses Projekts. Sie
%%% gehoeren Ulisses Spiele und stehen unter der Vereinbarung ueber
%%% Gemeinschaftsinhalte fuer SCRIPTORIUM AVENTURIS. Vor dem ersten Lauf:
%%%
%%%   python3 werkzeuge/aufbereiten.py "/pfad/zu/Scriptorium Aventuris v4"
%%%
%%% Naeheres in README.md. Ohne die Grafiken kompiliert nichts.
%%%
%%% Woher die Masse kommen: doku/MASSE.md. Kurz — der Klartext des Verlags
%%% auf Seite 2 des Baukasten-PDF, die Pixelmasse der Vorlagengrafiken bei
%%% 300 ppi, und die Rahmenmasse im IDML dort, wo ActualPpi und EffectivePpi
%%% gleich sind und das Bild also auf 100 Prozent liegt.
%%%
%%% Zeilen mit  % PRUEFEN:  sind nicht am Ergebnis geprueft. Diese Klasse ist
%%% aus gemessenen Massen geschrieben, aber bei ihrer Entstehung stand keine
%%% LaTeX-Installation zur Verfuegung.

\NeedsTeXFormat{LaTeX2e}
\ProvidesClass{dsa5latex}[2026/09/07 v2.0 DSA5-Satz nach Scriptorium Aventuris v4]

%%% ==================================================================
%%% 1  Optionen
%%% ==================================================================

\newif\ifdsa@raster        \dsa@rastertrue
\newif\ifdsa@rasterzeigen  \dsa@rasterzeigenfalse
\newif\ifdsa@entwurf       \dsa@entwurffalse

\DeclareOption{raster}{\dsa@rastertrue}
\DeclareOption{ohneraster}{\dsa@rasterfalse}
\DeclareOption{rasterzeigen}{\dsa@rasterzeigentrue}
\DeclareOption{entwurf}{\dsa@entwurftrue}
\DeclareOption*{\PassOptionsToClass{\CurrentOption}{article}}
\ProcessOptions\relax

% Basis ist article, nicht book: book bringt eine Kapitelmaschinerie mit, die
% hier vollstaendig ersetzt wuerde. twoside und twocolumn kommen von hier,
% damit \twocolumn[...] und figure* ohne Umstaende funktionieren.
\LoadClass[10pt,a4paper,twoside,twocolumn]{article}

%%% ==================================================================
%%% 2  Pakete
%%% ==================================================================

\RequirePackage{geometry}
\RequirePackage{graphicx}
\RequirePackage{xcolor}
\RequirePackage{fontspec}
\RequirePackage{polyglossia}
\RequirePackage{tikz}
\usetikzlibrary{calc}
\RequirePackage[most]{tcolorbox}
\RequirePackage{eso-pic}
\RequirePackage{fancyhdr}
\RequirePackage{enumitem}
\RequirePackage{wrapfig}
\RequirePackage[auto]{contour}
\RequirePackage{changepage}
\RequirePackage{intcalc}
\RequirePackage{array}
\RequirePackage{colortbl}
\RequirePackage{textcomp}
\RequirePackage{microtype}
\RequirePackage{hyperref}
\hypersetup{hidelinks}

\ifdsa@entwurf \setkeys{Gin}{draft} \fi

% Kein Mathematik-Schriftpaket. Ein Abenteuerheft braucht keinen Formelsatz,
% und ein Times-Mathefont neben Gentium-Text faellt bei jeder Ziffer auf.
% Wuerfel- und Probenangaben sind Text, siehe \dsaFormel.

%%% ==================================================================
%%% 3  Sprache
%%% ==================================================================
%
% Ohne Sprachunterstuetzung trennt LaTeX deutschen Text nach englischen
% Mustern. Bei 80,5 mm Spaltenbreite im Blocksatz faellt das auf jeder Seite
% auf. polyglossia ist unter XeLaTeX mit fontspec der eingespielte Weg.

\setdefaultlanguage[spelling=new]{german}
% PRUEFEN: Bricht der Lauf hier, auf \setdefaultlanguage{german} zurueckfallen
% — die Trennmuster sind dann trotzdem deutsch.

%%% ==================================================================
%%% 4  Grafikpfad
%%% ==================================================================
%
% Alle Grafiken liegen in grafiken/ und werden von
% werkzeuge/aufbereiten.py dort angelegt. Namen ohne Leerzeichen und
% Umlaute, weil LaTeX mit beidem schlecht umgeht.

\newcommand*{\dsagrafik}[1]{grafiken/#1}

%%% ==================================================================
%%% 5  Schriften
%%% ==================================================================
%
% Belegt in „Scriptorium Aventuris Lies mich zuerst v1.4.pdf":
%   Fliesstext             Gentium Basic, 10 pt
%   Kapitelueberschrift    Andalus, 23,5 pt
%   Unterkapitel           Andalus, 14 pt
%   Abschnittsueberschrift Gentium Basic, Fett, 13 pt
%   Unterabschnitt         Gentium Basic, Fett, 10 pt
%
% Ueber den Pfad gebunden, nicht ueber den Namen: keine systemweite
% Installation noetig, das Projekt ist ohne Vorbereitung baubar.

\defaultfontfeatures{Ligatures=TeX}

\setmainfont{GenBasR}[
  Path           = schriften/,
  Extension      = .ttf,
  BoldFont       = GenBasB,
  ItalicFont     = GenBasI,
  BoldItalicFont = GenBasBI ]

\newfontfamily{\dsaandalus}{andlso}[
  Path      = schriften/,
  Extension = .ttf ]
% PRUEFEN: Andalus hat nur einen Schnitt. Fett und kursiv rechnet XeLaTeX
% daraus selbst.

% Kapitaelchen. Keine der beiden Schriften hat das OpenType-Feature smcp —
% nachgesehen in allen fuenf Dateien. \textsc tut damit nichts, still und
% ohne Warnung. Deshalb nachgebildet: Versalien auf 82 Prozent.
\newlength{\dsa@kapgrad}
\DeclareRobustCommand*{\dsaKapitaelchen}[1]{%
  \setlength{\dsa@kapgrad}{0.82\dimexpr\f@size pt\relax}%
  {\fontsize{\the\dsa@kapgrad}{\baselineskip}\selectfont\MakeUppercase{#1}}}

% Zahlenangaben im Textmodus statt im Mathematikmodus.
\newcommand*{\dsaFormel}[1]{\mbox{#1}}
\newcommand*{\dsaMod}[2]{\mbox{\dsa@vorzeichen{#1}#2}}
\newcommand*{\dsa@vorzeichen}[1]{\if-#1\textminus\else#1\fi}
\newcommand*{\dsaMinus}{\textminus}
\newcommand*{\dsaMal}{\,\texttimes\,}

%%% ==================================================================
%%% 6  Farben
%%% ==================================================================
%
% Aus Resources/Graphic.xml des Baukasten-IDML, unveraendert.

\definecolor{dsatabellenrot}{RGB}{193,144,123}   % „Tabellenrot", #C1907B
\definecolor{dsadunkelrot}{cmyk}{0.51,0.91,0.81,0.06}
\definecolor{dsadunkelblau}{cmyk}{0.75,0.53,0.10,0.02}
\definecolor{dsagruenverlauf}{cmyk}{0.70,0.53,0.91,0.17}
\definecolor{dsapergamentgelb}{cmyk}{0.09,0.26,0.56,0.09}  % „Fuer Gelb"
\definecolor{dsawesenzug}{cmyk}{0.64,0.17,0.82,0.13}
\definecolor{dsatuerkis}{RGB}{0,176,240}
\definecolor{dsaprofession}{RGB}{170,105,46}     % aus LAB umgerechnet
\definecolor{dsatabellenlinie}{HTML}{BFBFBF}
\definecolor{dsazitat}{HTML}{404040}

%%% ==================================================================
%%% 7  Satzspiegel
%%% ==================================================================
%
% Wortlaut Baukasten, Seite 2:
%   „Spalten: Zwei Spalten, 5 mm Abstand zueinander.
%    Textbereich-Raender: 20mm Rand-Abstand innen, 24mm aussen, oben und unten.
%    Grafikbereich-Raender: 13mm Rand-Abstand innen und aussen, 19,25mm unten,
%    12,75mm oben.
%    Raster: 12pt. Grundlinienraster ab 12,7mm.
%    Anschnitt: 3mm Anschnitt; fuers Scriptorium unerheblich."
%
% Satzbreite 210 - 20 - 24 = 166 mm, Spalte (166 - 5)/2 = 80,5 mm.
% Satzhoehe auf 59 Grundlinien: 12pt + 58*12pt = 708pt = 249,66 mm, also
% 0,66 mm mehr als die 249 mm des Baukastens, damit 59 Zeilen ins Raster
% passen — der Wert der offiziellen Baende.

\geometry{
  a4paper, twoside,
  inner=20mm, outer=24mm, top=24mm,
  textheight=708pt,
  ignorehead, headheight=0pt, headsep=0pt,
  ignorefoot, footskip=10mm}

\setlength{\columnsep}{5mm}

% Der Grafikbereich, der zweite Rahmen des Baukastens
\newlength{\dsagrafikbreite}  \setlength{\dsagrafikbreite}{184mm}
\newlength{\dsagrafikhoehe}   \setlength{\dsagrafikhoehe}{265mm}
\newlength{\dsagrafikoben}    \setlength{\dsagrafikoben}{12.75mm}

% Anschnitt: 3 mm sind in den Grafiken angelegt, werden fuer ein
% Bildschirm-PDF aber nicht genutzt. Der Baukasten sagt selbst „fuers
% Scriptorium unerheblich". Die Hintergrundgrafiken liegen dennoch mit
% Zugabe ueber dem Papierrand, sonst blieben weisse Raender.
\newlength{\dsabeschnitt}     \setlength{\dsabeschnitt}{3mm}

%%% ==================================================================
%%% 8  Grundlinienraster
%%% ==================================================================
%
% Der Baukasten begruendet es selbst: „es fuehrt auch dazu, dass die
% Textzeilen bei zwei Spalten immer auf einer Hoehe sind". Am offiziellen PDF
% nachgemessen liegen alle Grundlinien auf 36 + 12*k pt unter der Oberkante,
% und die Abstaende sind ausschliesslich 12, 24, 36 oder 72 pt.

\newlength{\dsaRastermass}    \setlength{\dsaRastermass}{12pt}
\newcommand*{\dsaRaster}[1]{#1\dsaRastermass}
\newcommand*{\dsaRasterluft}[1]{\vspace*{\dsaRaster{#1}}}

\ifdsa@raster
  \setlength{\topskip}{12pt}
  \setlength{\parskip}{0pt}
  \setlength{\parindent}{1em}   % PRUEFEN: am offiziellen PDF nachmessen
  \flushbottom
\fi

\ifdsa@rasterzeigen
  \AddToShipoutPictureFG{%
    \begin{tikzpicture}[remember picture, overlay]
      \foreach \n in {0,1,...,66}{%
        \draw[dsatuerkis, line width=0.1pt, opacity=0.5]
          ([shift={(0pt,-36pt-\n*12pt)}]current page.north west) --
          ([shift={(0pt,-36pt-\n*12pt)}]current page.north east);}
      \draw[dsadunkelrot, line width=0.3pt, opacity=0.6]
        ([shift={(0pt,-24mm)}]current page.north west) --
        ([shift={(0pt,-24mm)}]current page.north east);
    \end{tikzpicture}}
\fi

%%% ==================================================================
%%% 9  Bilder deckend zuschneiden
%%% ==================================================================
%
% \includegraphics mit Breite UND Hoehe streckt. Der Verlag macht es anders;
% der Nutzerleitfaden der Wordvorlage beschreibt den Weg: „Die
% Szenen-Illustration ist zu klein und fuellt den Rahmen nicht aus. [...]
% Daher musst du die Grafik noch groesser skalieren und zuschneiden."
%
% Das braucht kein Bildwerkzeug: TeX misst das Bild aus, vergleicht sein
% Seitenverhaeltnis mit dem Ziel, skaliert an der passenden Kante, und TikZ
% beschneidet.
%
% \dsaBildDeckend{<Breite>}{<Hoehe>}{<Bild>}
\newsavebox{\dsa@bildbox}
\newcommand{\dsaBildDeckend}[3]{%
  \sbox\dsa@bildbox{\includegraphics{#3}}%
  \pgfmathsetmacro{\dsa@bildverh}{\wd\dsa@bildbox/\ht\dsa@bildbox}%
  \pgfmathsetmacro{\dsa@zielverh}{(#1)/(#2)}%
  \begin{tikzpicture}
    \clip ({-0.5*(#1)},{-0.5*(#2)}) rectangle ({0.5*(#1)},{0.5*(#2)});
    \ifdim\dsa@bildverh pt>\dsa@zielverh pt
      \node[anchor=center, inner sep=0] at (0,0) {\includegraphics[height=#2]{#3}};
    \else
      \node[anchor=center, inner sep=0] at (0,0) {\includegraphics[width=#1]{#3}};
    \fi
  \end{tikzpicture}}
% PRUEFEN: Der Vergleich laeuft ueber zwei pgfmath-Makros, die als Laengen in
% pt verglichen werden. Wenn er bricht, mit \pgfmathparse und \pgfmathresult
% umbauen.
% PRUEFEN: Der Beschnitt ist mittig. Bei einem Portrait sitzt der Kopf oft
% oben; dann braucht es einen Versatz.

% Kreisrund beschnitten, deckend skaliert.
\newcommand{\dsaBildKreis}[2]{%
  \begin{tikzpicture}
    \clip circle ({0.5*(#1)});
    \node[anchor=center, inner sep=0] at (0,0) {\dsaBildDeckend{#1}{#1}{#2}};
  \end{tikzpicture}}

% Freihaendige Form. Punkte als TikZ-Koordinaten, etwa {(0,0) (2,1) (3,-1)}.
\newcommand{\dsaBildForm}[4]{%
  \begin{tikzpicture}
    \clip plot [smooth cycle] coordinates {#3};
    \node[anchor=center, inner sep=0] at (0,0) {\dsaBildDeckend{#1}{#2}{#4}};
  \end{tikzpicture}}

% Echte Softmaske aus einer Graustufengrafik: weiss deckt, schwarz laesst
% durchscheinen. Der einzige Weg fuer Freiform, bei der der Hintergrund
% wirklich durchkommen soll.
\newcommand{\dsaBildMaskiert}[4]{%
  \pgfdeclarefading{dsa@fading}{\includegraphics[width=#2,height=#3]{#1}}%
  \begin{tikzpicture}
    \node[anchor=center, inner sep=0, path fading=dsa@fading] at (0,0)
      {\dsaBildDeckend{#2}{#3}{#4}};
  \end{tikzpicture}}
% PRUEFEN: Fadings sind Transparenzgruppen und brauchen einen Treiber, der
% sie kann. Unter XeLaTeX laufen sie, sind aber weniger erprobt als unter
% pdflatex.

%%% ==================================================================
%%% 10  Seitenhintergrund
%%% ==================================================================
%
% Die Seiten sind 2516 x 3579 px = 213,0 x 303,0 mm — A4 plus 3 mm Anschnitt
% oben, unten und aussen, keiner am Bund. So schneidet
% werkzeuge/aufbereiten.py die vier Doppelseiten des Baukastens auseinander;
% eine Doppelseite ist 426,0 x 303,0 mm, der Schnitt liegt in der Mitte.
%
% Vier Varianten rotieren nach Doppelseite. Der Baukasten hat vier
% Hintergruende; die aeltere LaTeX-Vorlage nutzte nur drei.

\newif\ifdsa@bgaus \dsa@bgausfalse
\newcommand*{\dsaHintergrundAus}{\global\dsa@bgaustrue}
\newcommand*{\dsaHintergrundAn}{\global\dsa@bgausfalse}

% Ganzzahlige Division und Rest — \numexpr rundet kaufmaennisch und taugt
% dafuer nicht.
\newcommand*{\dsa@bgvariante}{\intcalcMod{\intcalcDiv{\value{page}}{2}}{4}}

\AddToShipoutPictureBG{%
  \ifdsa@bgaus\else
    \begin{tikzpicture}[remember picture, overlay]
      \ifodd\value{page}
        \node[anchor=north east, inner sep=0]
          at ([shift={(\dsabeschnitt,\dsabeschnitt)}]current page.north east)
          {\includegraphics[width=213mm,height=303mm]{\dsagrafik{seite-rechts-\dsa@bgvariante}}};
      \else
        \node[anchor=north west, inner sep=0]
          at ([shift={(-\dsabeschnitt,\dsabeschnitt)}]current page.north west)
          {\includegraphics[width=213mm,height=303mm]{\dsagrafik{seite-links-\dsa@bgvariante}}};
      \fi
    \end{tikzpicture}%
  \fi}
% PRUEFEN: Ob der Anker an der Aussenkante die Zierleisten richtig trifft,
% zeigt der erste Abzug. Bleibt ein weisser Streifen, ist der Anker falsch
% gewaehlt, nicht das Mass. Und: die Folge muss 0,0,1,1,2,2,3,3 sein.

%%% ==================================================================
%%% 11  Fusszeile
%%% ==================================================================

\pagestyle{fancy}
\fancyhf{}
\renewcommand{\headrulewidth}{0pt}
\renewcommand{\footrulewidth}{0pt}
\contourlength{0.6pt}
\newcommand*{\dsa@seitenzahl}{%
  {\dsaandalus\fontsize{14}{14}\selectfont
   \contour{black}{\textcolor{white}{\thepage}}}}
\fancyfoot[LE]{\dsa@seitenzahl}
\fancyfoot[RO]{\dsa@seitenzahl}

%%% ==================================================================
%%% 12  Gliederung
%%% ==================================================================
%
% Kapitelbanner: 210,1 x 43,2 mm, papierbreit. Es steht ueber
% \twocolumn[...], dessen optionales Argument ueber die volle Satzbreite
% gesetzt wird — damit beginnen BEIDE Spalten darunter. Ein tikz-Overlay
% nimmt keinen Platz ein und ein \vspace danach wirkt nur in der Spalte, in
% der er steht; die zweite Spalte liefe hinter das Banner.

\newcounter{dsakapitel}
\newlength{\dsabannerversatz} \setlength{\dsabannerversatz}{0mm}
% Der Baukasten setzt das Banner an die Papierkante. In gesetzten
% Scriptorium-Abenteuern sitzt es 16 bis 25 mm darunter — als Laenge
% gehalten, damit es sich ohne Eingriff verschieben laesst.

\newcommand*{\dsa@bannerblock}[1]{%
  \begin{tikzpicture}[remember picture, overlay]
    \node[anchor=north, inner sep=0]
      at ([shift={(0pt,-\dsabannerversatz)}]current page.north)
      {\includegraphics[width=210.1mm]{\dsagrafik{kapitelbanner}}};
    \node[anchor=north, inner sep=0, text width=150mm, align=center]
      at ([shift={(0pt,-22mm-\dsabannerversatz)}]current page.north)
      {\dsaandalus\fontsize{23.5}{28.2}\selectfont
       \MakeUppercase{Kapitel \thedsakapitel: #1}};
  \end{tikzpicture}%
  \dsaRasterluft{10}}
% PRUEFEN: Titelzeile 22 mm unter der Kante, mittig auf 150 mm — geschaetzt,
% am Banner nachmessen. Bei zweizeiligen Titeln reichen 10 Rastereinheiten
% nicht.

% \dsakapitel[<Bild>]{<Titel>}
% Reihenfolge: erst \twocolumn, also neue Seite plus Banner, dann das
% Kapitelbild — sonst landet das Bild auf der Vorseite.
\newcommand{\dsakapitel}[2][]{%
  \stepcounter{dsakapitel}%
  \twocolumn[\dsa@bannerblock{#2}]%
  \addcontentsline{toc}{section}{\thedsakapitel\quad #2}%
  \if\relax\detokenize{#1}\relax\else\dsaKapitelbild{#1}\fi}

% Kapitelbild in der Bauweise des Verlags: Pergamentflaeche, darauf das Bild
% leicht eingerueckt, sodass der Pergamentrand als Rahmen stehen bleibt, und
% darueber unten mittig das Drachenornament. Keine Maske.
%
% Nachgesehen in DSA5-Kapitelstart-Beispielgrafik.psd: die Gruppe
% „Vertikaler_Halbseiter" enthaelt „Pergament fuer Bild" und darueber einen
% weissen Platzhalter, der eingerueckt sitzt; dazu kommt das Ornament.
% werkzeuge/aufbereiten.py legt beide Teile deckungsgleich auf voller
% Leinwand ab, 109,2 x 300,0 mm.
\newlength{\dsakapitelbildrand} \setlength{\dsakapitelbildrand}{3.5mm}
% PRUEFEN: geschaetzt. Am Pergament nachmessen, wie breit der sichtbare Rand
% sein soll.

\newcommand{\dsaKapitelbild}[1]{%
  \begin{tikzpicture}[remember picture, overlay]
    \ifodd\value{page}
      \def\dsa@kbanker{north east}%
      \def\dsa@kbversatz{\dsabeschnitt}%
    \else
      \def\dsa@kbanker{north west}%
      \def\dsa@kbversatz{-\dsabeschnitt}%
    \fi
    \node[anchor=\dsa@kbanker, inner sep=0] (dsakb)
      at ([shift={(\dsa@kbversatz,\dsabeschnitt)}]current page.\dsa@kbanker)
      {\includegraphics[width=109.2mm,height=300mm]{\dsagrafik{kapitelstart-pergament}}};
    \node[anchor=center, inner sep=0] at (dsakb.center)
      {\dsaBildDeckend{\dimexpr109.2mm-2\dsakapitelbildrand\relax}%
                      {\dimexpr300mm-2\dsakapitelbildrand\relax}{#1}};
    \node[anchor=center, inner sep=0] at (dsakb.center)
      {\includegraphics[width=109.2mm,height=300mm]{\dsagrafik{kapitelstart-ornament}}};
  \end{tikzpicture}}
% Pergament und Ornament sind native 109,2 x 300,0 mm — beide Masse zu
% erzwingen ist hier exakt, nicht Streckung.
% Steht ein Kapitelbild, muss die Anfangsseite mit \dsaKapitelseiteEnde
% beendet werden, sonst laeuft der Text dahinter.
\newcommand*{\dsaKapitelseiteEnde}{\clearpage}

% Unterkapitel: Andalus 14 pt, zentriert, 12 pt danach — Absatzformat
% „Absatzueberschrift" des Baukastens.
\newcommand{\dsaunterkapitel}[1]{%
  \par\dsaRasterluft{1}%
  \addcontentsline{toc}{subsection}{#1}%
  {\centering\dsaandalus\fontsize{14}{16.8}\selectfont #1\par}%
  \dsaRasterluft{1}\nobreak}

\newcommand{\dsaabschnitt}[1]{%
  \par\dsaRasterluft{1}%
  {\bfseries\fontsize{13}{15.6}\selectfont #1\par}\nobreak}

\newcommand{\dsaunterabschnitt}[1]{%
  \par{\bfseries #1\par}\nobreak}

% Abschnitt mit Pergamentverlauf, Farbfeld „Fuer Gelb" des Baukastens.
\newcommand{\dsaAbschnittGelb}[1]{%
  \par\dsaRasterluft{1}%
  \noindent\begin{tcolorbox}[
    enhanced, blankest, nobeforeafter, width=\linewidth,
    left=2mm, right=2mm, top=1mm, bottom=1mm,
    interior style={left color=dsapergamentgelb, right color=white}]
    \bfseries\fontsize{13}{15.6}\selectfont #1
  \end{tcolorbox}\par
  \dsaRasterluft{1}}

%%% ==================================================================
%%% 13  Kaesten
%%% ==================================================================
%
% Alle Masse sind Produktionsgroessen. Die Spalte ist 80,5 mm, die Kaesten
% sind 84,4 bis 86,9 mm breit — sie ragen bewusst darueber hinaus, weil der
% Zierrand ausserhalb des Textbereichs liegt.
%
% Der reservierte senkrechte Raum ist auf ganze Rastereinheiten aufgerundet,
% damit der Text darunter wieder auf der Grundlinie sitzt. Die Differenz von
% hoechstens 2,4 mm bleibt unten leer und ist unsichtbar, weil dort der
% Seitenhintergrund durchscheint.
%
%   Grafik                     Mass mm       Raster  Rest mm
%   pergament-klein            85,5 x  50,7    12     +0,08
%   pergament-mittel           85,5 x  99,5    24     +2,10
%   pergament-lang             85,5 x 192,4    46     +2,35
%   werte-klein                84,4 x  54,8    13     +0,23
%   werte-mittel               86,9 x 103,8    25     +2,03
%   werte-gross                85,0 x 197,1    47     +1,89
%   werte-klein-portrait       94,0 x  59,2    14     +0,07
%   werte-mittel-portrait      94,0 x 104,0    25     +1,83
%   werte-gross-portrait       94,0 x 199,1    47     -0,11
%   meister-schmal             59,9 x 114,2    27     +0,10
%   meister-breit             177,9 x 114,2    27     +0,10
%   meister-maske              84,0 x 108,0    26     +2,07
%   meister-maske-klein        84,0 x  45,0    11     +1,57

\newlength{\dsakasteninnen}  \setlength{\dsakasteninnen}{8mm}
\newlength{\dsakastenoben}   \setlength{\dsakastenoben}{6mm}
% PRUEFEN: beide geschaetzt und fuer alle Kaesten gueltig. Am ersten Abzug
% nachmessen, wie weit der Zierrand der Grafik nach innen reicht.

\tcbset{dsa@grundkasten/.style={
  enhanced, breakable=false, blankest, nobeforeafter, valign=top,
  left=\dsakasteninnen, right=\dsakasteninnen,
  top=\dsakastenoben,   bottom=\dsakastenoben}}

\tcbset{dsaueberhang/.style={grow to left by=#1, grow to right by=#1}}

% \dsaKastenNeu{<Umgebung>}{<Breite>}{<Grafikhoehe>}{<Rastereinheiten>}
%              {<Grafik>}{<weitere Schluessel>}
\newcommand{\dsaKastenNeu}[6]{%
  \newtcolorbox{#1}[1][]{%
    dsa@grundkasten,
    width=#2, height=\dsaRaster{#4},
    underlay={\node[anchor=north west, inner sep=0] at (frame.north west)
      {\includegraphics[width=#2,height=#3]{\dsagrafik{#5}}};},
    #6, ##1}}

% ---- Pergament ----
\dsaKastenNeu{dsaPergamentKlein} {85.5mm} {50.7mm} {12}{pergament-klein} {dsaueberhang=2.5mm}
\dsaKastenNeu{dsaPergamentMittel}{85.5mm} {99.5mm} {24}{pergament-mittel}{dsaueberhang=2.5mm}
\dsaKastenNeu{dsaPergamentLang}  {85.5mm} {192.4mm}{46}{pergament-lang}  {dsaueberhang=2.5mm}
% Breit und schmal passen nicht in eine Spalte — einspaltig setzen.
\dsaKastenNeu{dsaPergamentBreit} {136.9mm}{192.4mm}{46}{pergament-breit} {}
\dsaKastenNeu{dsaPergamentSchmal}{48.9mm} {192.4mm}{46}{pergament-schmal}{left=6mm,right=6mm}

% ---- Wertekaesten ----
\dsaKastenNeu{dsaWerteKlein} {84.4mm}{54.8mm} {13}{werte-klein} {dsaueberhang=1.95mm,left=7mm,right=7mm}
\dsaKastenNeu{dsaWerteMittel}{86.9mm}{103.8mm}{25}{werte-mittel}{dsaueberhang=3.2mm,left=7mm,right=7mm}
\dsaKastenNeu{dsaWerteGross} {85.0mm}{197.1mm}{47}{werte-gross} {dsaueberhang=2.25mm,left=7mm,right=7mm}

% ---- Wertekaesten mit Portrait ----
%
% Alle drei sind 94,0 mm breit; das Medaillon tritt 13,5 mm zur Aussenseite
% heraus. Vorlaeufig nur die rechte Lage — der Baukasten liefert die Grafik
% nur in einer Richtung.
%
% Das Portraitbild kommt als Schluessel, damit es im underlay landet: den
% TikZ-Knoten „frame" gibt es nur dort, nicht im Kasteninhalt.

\newlength{\dsaportraitgroesse} \setlength{\dsaportraitgroesse}{30mm}
\newlength{\dsaportraitx}       \setlength{\dsaportraitx}{17mm}
\newlength{\dsaportraity}       \setlength{\dsaportraity}{17mm}
% PRUEFEN: alle drei geschaetzt. Der Ring in portraitrahmen.png ist im IDML
% 35,4 x 35,0 mm gerahmt; der Innenkreis ist kleiner.

\tcbset{dsaportrait/.style={underlay app={%
  \node[inner sep=0] at ([shift={(-\dsaportraitx,-\dsaportraity)}]frame.north east)
    {\dsaBildKreis{\dsaportraitgroesse}{#1}};}}}

\dsaKastenNeu{dsaWerteKleinPortrait} {94.0mm}{59.2mm} {14}{werte-klein-portrait} {grow to right by=13.5mm,left=7mm,right=24mm}
\dsaKastenNeu{dsaWerteMittelPortrait}{94.0mm}{104.0mm}{25}{werte-mittel-portrait}{grow to right by=13.5mm,left=7mm,right=24mm}
\dsaKastenNeu{dsaWerteGrossPortrait} {94.0mm}{199.1mm}{47}{werte-gross-portrait} {grow to right by=13.5mm,left=7mm,right=24mm}

% ---- Graue Kaesten ----
%
% meister-schmal ist HOCHKANT, 59,9 x 114,2 mm. meister-breit ist mit
% 177,9 mm breiter als die Satzbreite von 166 mm und ragt je Seite 5,95 mm
% hinaus — einspaltig setzen.
\dsaKastenNeu{dsaMeisterSchmal}    {59.9mm} {114.2mm}{27}{meister-schmal}     {coltext=white,left=6mm,right=6mm,top=8mm,bottom=8mm}
\dsaKastenNeu{dsaMeisterBreit}     {177.9mm}{114.2mm}{27}{meister-breit}      {coltext=white,dsaueberhang=5.95mm,left=10mm,right=10mm,top=8mm,bottom=8mm}
\dsaKastenNeu{dsaMeisterMaske}     {84.0mm} {108.0mm}{26}{meister-maske}      {coltext=white,dsaueberhang=1.75mm,left=7mm,right=7mm,top=10mm,bottom=8mm}
\dsaKastenNeu{dsaMeisterMaskeKlein}{84.0mm} {45.0mm} {11}{meister-maske-klein}{coltext=white,dsaueberhang=1.75mm,left=7mm,right=7mm,top=10mm,bottom=6mm}

% ---- Kasten in freier Hoehe ----
%
% Der Weg des Verlags. Der Baukasten sagt es selbst: „Die Wertekaesten in
% unseren Buechern sind normalerweise eine Kombination aus verschiedenen
% Elementen: Pergamentkaesten von Seite 2/3, sowie die Zierleisten und ggf.
% den Portrait-Rahmen von Seite 10." Und zum Abstand: „Feste Abstaende fuer
% Objekte haben wir nicht." Die fertigen Kaesten sind Bequemlichkeit, nicht
% das Verfahren.
\newenvironment{dsaKastenFrei}[2][]{%
  \begin{tcolorbox}[
    dsa@grundkasten,
    width=85.5mm, height=\dsaRaster{#2},
    dsaueberhang=2.5mm, top=8mm, bottom=8mm,
    underlay={%
      \node[anchor=north west, inner sep=0] at (frame.north west)
        {\includegraphics[width=85.5mm,height=\dsaRaster{#2}]{\dsagrafik{pergament-lang}}};
      \node[anchor=north, inner sep=0] at (frame.north)
        {\includegraphics[width=52.8mm,height=9.8mm]{\dsagrafik{trenner-oben}}};
      \node[anchor=south, inner sep=0] at (frame.south)
        {\includegraphics[width=52.8mm,height=9.8mm]{\dsagrafik{trenner-unten}}};},
    #1]%
}{\end{tcolorbox}}
% PRUEFEN: Die Pergamentflaeche wird in der Hoehe gestreckt, und
% pergament-lang hat auch in der Flaeche eine gezeichnete Kante. Sauberer
% waere ein Mittelstreifen zum Kacheln.

%%% ==================================================================
%%% 14  Vorlesetext, Meistermaske, NSC-Kopf
%%% ==================================================================

\newcommand{\dsaVorlesetext}[1]{%
  \par\dsaRasterluft{1}%
  \noindent\includegraphics[width=\linewidth]{\dsagrafik{vorlesetext}}%
  \par\nobreak #1\par
  \dsaRasterluft{1}}
% PRUEFEN: Die Leiste ist native 158,5 x 29,5 mm und wird hier auf
% Spaltenbreite gestaucht. Ob der Vorlesetext kursiv gesetzt wird, sagt der
% Baukasten nicht — hier aufrecht.

% Der Baukasten liefert die Meistermaske MIT gestrichelter Verbindung als
% fertige Grafik in drei Hoehen — deshalb keine TikZ-Konstruktion.
%   1  48,9 x 38,9 mm    9 Rastereinheiten
%   2  48,9 x 65,8 mm   16
%   3  48,9 x 96,4 mm   23
\newcommand{\dsaMeistermaske}[2][2]{%
  \par\dsaRasterluft{1}\noindent
  \ifcase\numexpr#1-1\relax
    \includegraphics[width=48.9mm,height=38.9mm]{\dsagrafik{meistermaske-1}}%
  \or
    \includegraphics[width=48.9mm,height=65.8mm]{\dsagrafik{meistermaske-2}}%
  \or
    \includegraphics[width=48.9mm,height=96.4mm]{\dsagrafik{meistermaske-3}}%
  \fi
  \par{\small #2\par}\dsaRasterluft{1}}

\newcommand*{\dsaNSCkopf}{%
  \noindent\includegraphics[width=\linewidth]{\dsagrafik{nsc-kopf}}\par\nobreak}

%%% ==================================================================
%%% 15  Marken im Text
%%% ==================================================================

\newcommand*{\dsaAugeSchwarz}{%
  \smash{\raisebox{0.25\height}{\includegraphics[width=3mm]{\dsagrafik{auge-schwarz}}}}}
\newcommand*{\dsaAugeWeiss}{%
  \smash{\raisebox{0.25\height}{\includegraphics[width=3mm]{\dsagrafik{auge-weiss}}}}}
% PRUEFEN: 3 mm gewaehlt. Im IDML sitzen die Augen als verankerte Objekte im
% Text und haben kein eigenes Rahmenmass — Sollgroesse offen.

\newcommand{\dsaFokusregel}[1]{%
  \smash{\raisebox{-0.4\height}{%
    \begin{tikzpicture}
      \node[inner sep=0] {\includegraphics[width=9.9mm]{\dsagrafik{fokusregel}}};
      \node[inner sep=0] {\footnotesize #1};
    \end{tikzpicture}}}}

\newcommand{\dsaFiole}[1]{%
  \begin{wrapfigure}{#1}{9.1mm}
    \centering\vspace*{-\dsaRaster{1}}%
    \includegraphics[width=9.1mm]{\dsagrafik{fiole}}%
    \vspace*{-\dsaRaster{1}}%
  \end{wrapfigure}}
\newcommand{\dsaSchaedel}[1]{%
  \begin{wrapfigure}{#1}{9.1mm}
    \centering\vspace*{-\dsaRaster{1}}%
    \includegraphics[width=9.1mm]{\dsagrafik{totenkopf}}%
    \vspace*{-\dsaRaster{1}}%
  \end{wrapfigure}}

% Gegnerabstufung. Verschiedene Seitenverhaeltnisse, deshalb ueber die Hoehe.
\newcommand*{\dsa@figur}[1]{%
  \smash{\raisebox{-0.15\height}{\includegraphics[height=4mm]{\dsagrafik{#1}}}}}
\newcommand*{\dsaBauer}{\dsa@figur{icon-bauer}}
\newcommand*{\dsaSpringer}{\dsa@figur{icon-springer}}
\newcommand*{\dsaTurm}{\dsa@figur{icon-turm}}
\newcommand*{\dsaKoenig}{\dsa@figur{icon-koenig}}
% PRUEFEN: 4 mm gewaehlt, nicht belegt.

% Rautenskalen, selbst gezeichnet. Der Baukasten hat sie nicht als Grafik.
\newcommand*{\dsa@rauten}[3]{%
  \begin{tikzpicture}[baseline=-0.6ex]
    \pgfmathsetlengthmacro{\dsa@rautekante}{#3/4.6}%
    \foreach \i in {1,...,4}{%
      \ifnum\i>#2
        \draw[#1, line width=0.4pt] ({(\i-1)*1.15*\dsa@rautekante},0)
          -- ++({0.5*\dsa@rautekante},{0.5*\dsa@rautekante})
          -- ++({0.5*\dsa@rautekante},{-0.5*\dsa@rautekante})
          -- ++({-0.5*\dsa@rautekante},{-0.5*\dsa@rautekante}) -- cycle;
      \else
        \fill[#1] ({(\i-1)*1.15*\dsa@rautekante},0)
          -- ++({0.5*\dsa@rautekante},{0.5*\dsa@rautekante})
          -- ++({0.5*\dsa@rautekante},{-0.5*\dsa@rautekante})
          -- ++({-0.5*\dsa@rautekante},{-0.5*\dsa@rautekante}) -- cycle;
      \fi}
  \end{tikzpicture}}
\newcommand*{\dsaRautenRot}[2]{\dsa@rauten{dsadunkelrot}{#1}{#2}}
\newcommand*{\dsaRautenGruen}[2]{\dsa@rauten{dsagruenverlauf}{#1}{#2}}
% PRUEFEN: Kantenlaenge ist die Breite geteilt durch 4,6 — vier Rauten plus
% drei Luecken von je 15 Prozent. Mit den offiziellen vergleichen.

\newcommand*{\dsaBand}[2]{\textsuperscript{#1\,#2}}

%%% ==================================================================
%%% 16  Aufzaehlungen und Absatzformen
%%% ==================================================================

\newlist{dsaliste}{itemize}{4}
\setlist[dsaliste,1]{
  leftmargin=\dimexpr 6mm+\labelsep\relax,
  topsep=0pt, itemsep=0pt, parsep=0pt,
  label={\smash{\raisebox{-0.25\height}{%
    \includegraphics[height=2.4mm]{\dsagrafik{aufzaehlung}}}}}}

\newlist{dsalisteblau}{itemize}{4}
\setlist[dsalisteblau,1]{
  leftmargin=\dimexpr 6mm+\labelsep\relax,
  topsep=0pt, itemsep=0pt, parsep=0pt,
  label={\smash{\raisebox{-0.25\height}{%
    \includegraphics[height=2.4mm]{\dsagrafik{aufzaehlung-blau}}}}}}

\newlist{dsalisterot}{itemize}{4}
\setlist[dsalisterot,1]{
  leftmargin=\dimexpr 6mm+\labelsep\relax,
  topsep=0pt, itemsep=0pt, parsep=0pt,
  label={\smash{\raisebox{-0.25\height}{%
    \includegraphics[height=2.4mm]{\dsagrafik{aufzaehlung-rot}}}}}}

% Haengender Einzug, Absatzformat „Werte" des Baukastens: -8,504 pt
\newenvironment{dsaWerteabsatz}{%
  \par\setlength{\parindent}{0pt}%
  \setlength{\hangindent}{8.504pt}\hangafter=1
}{\par}

\newcommand{\dsaEinfuehrung}[1]{%
  {\itshape\addfontfeature{LetterSpace=1.0}#1\par}}

% Stimmungstext. Die Wordvorlage beschreibt ihn genau: Pfeile nach innen,
% nicht kursiv; Text kursiv im Blocksatz; kein Leerzeichen zwischen Pfeil und
% Text; vor der Quelle ein Bindestrich; Quelle kursiv, ohne Schlusspunkt.
\newcommand{\dsaStimmung}[2]{%
  \par\dsaRasterluft{1}%
  {\textup{\guillemotright\guillemotright}\itshape #1\textup{\guillemotleft\guillemotleft}\par
   \hfill\itshape -- #2\par}%
  \dsaRasterluft{1}}

\newcommand{\dsaZitat}[1]{%
  \par\dsaRasterluft{1}%
  {\centering\color{dsazitat}\itshape #1\par}%
  \dsaRasterluft{1}}

%%% ==================================================================
%%% 17  Tabellen
%%% ==================================================================
%
% Kopfleiste mit Verlauf von „Tabellenrot" nach Weiss, Linien in #BFBFBF.
% Der Baukasten warnt: Objekte mit Farbverlauf gehoeren auf „Multiplizieren".

\newcommand{\dsaTabellenkopf}[1]{%
  \noindent\begin{tcolorbox}[
    enhanced, blankest, nobeforeafter, width=\linewidth,
    left=1.5mm, right=1.5mm, top=0.5mm, bottom=0.5mm,
    interior style={left color=dsatabellenrot, right color=white}]
    \bfseries #1
  \end{tcolorbox}}
% PRUEFEN: „blend mode=multiply" braeuchte einen Treiber, der Mischmodi kann.
% Unter XeLaTeX nicht selbstverstaendlich, deshalb weggelassen — auf weissem
% Grund faellt der Unterschied nicht auf.

\newcommand*{\dsaTabellenlinie}{\arrayrulecolor{dsatabellenlinie}}

%%% ==================================================================
%%% 18  Seitentypen
%%% ==================================================================

% ---- Umschlag vorne ----
% umschlag-vorne ist 216,0 x 303,0 mm — A4 plus 3 mm auf allen vier Seiten.
% Titel Andalus 28 pt fett laut Baukasten.
\newlength{\dsatitelzeileeins} \setlength{\dsatitelzeileeins}{95mm}
\newlength{\dsatitelzeilezwei} \setlength{\dsatitelzeilezwei}{115mm}
% PRUEFEN: beide Lagen geschaetzt, am Coverrahmen nachmessen.

\newcommand{\dsaUmschlagVorne}[3]{%
  \dsaHintergrundAus
  \thispagestyle{empty}%
  \begin{tikzpicture}[remember picture, overlay]
    \node[anchor=center, inner sep=0] at (current page.center)
      {\dsaBildDeckend{216mm}{303mm}{#1}};
    \node[anchor=center, inner sep=0] at (current page.center)
      {\includegraphics[width=216mm,height=303mm]{\dsagrafik{umschlag-vorne}}};
    \node[anchor=north, text width=170mm, align=center, inner sep=0]
      at ([shift={(0pt,-\dsatitelzeileeins)}]current page.north)
      {\dsaandalus\fontsize{28}{33.6}\selectfont\bfseries
       \contour{black}{\textcolor{white}{#2}}};
    \node[anchor=north, text width=170mm, align=center, inner sep=0]
      at ([shift={(0pt,-\dsatitelzeilezwei)}]current page.north)
      {\dsaandalus\fontsize{28}{33.6}\selectfont\bfseries
       \contour{black}{\textcolor{white}{#3}}};
  \end{tikzpicture}%
  \clearpage\dsaHintergrundAn}

% ---- Umschlag hinten ----
\newcommand{\dsaUmschlagHinten}[3]{%
  \clearpage\dsaHintergrundAus\onecolumn
  \thispagestyle{empty}%
  \begin{tikzpicture}[remember picture, overlay]
    \node[anchor=center, inner sep=0] at (current page.center)
      {\dsaBildDeckend{216mm}{303mm}{#1}};
  \end{tikzpicture}%
  {\dsaandalus\fontsize{23.5}{28.2}\selectfont #2\par}%
  \dsaRasterluft{2}#3\par
  \clearpage\dsaHintergrundAn}
% PRUEFEN: Der Textblock ist noch nicht am Rahmen ausgerichtet.

% ---- Impressum ----
\newenvironment{dsaImpressumseite}{%
  \clearpage\onecolumn
  \thispagestyle{empty}\small
}{%
  \clearpage\twocolumn}

\newcommand{\dsaImpressumsblock}[2]{%
  \par\noindent{\bfseries #1}\par\nobreak\noindent #2\par\dsaRasterluft{1}}

% Der Wortlaut, der laut Baukasten „stets im Werk enthalten sein" muss.
\newcommand{\dsaRechtstext}[1]{%
  Dieses Produkt wurde unter Lizenz erstellt. Das Schwarze Auge und sein Logo
  sowie Aventuria, Dere, Myranor, Riesland, Tharun, Uthuria, The Dark Eye und
  ihre Logos sind eingetragene Marken von Ulisses Medien und Spiele
  Distribution GmbH in Deutschland, den U.S.A. und anderen Ländern.\par
  Ulisses Spiele und sein Logo sind eingetragene Marken der Ulisses Medien und
  Spiele Distribution GmbH.\par
  Dieses Werk enthält Material, das durch Ulisses Spiele und/oder andere
  Autoren urheberrechtlich geschützt ist. Solches Material wird mit Erlaubnis
  im Rahmen der Vereinbarung über Gemeinschaftsinhalte für SCRIPTORIUM
  AVENTURIS verwendet.\par
  Alle anderen Originalmaterialien in diesem Werk sind Copyright #1 und werden
  im Rahmen der Vereinbarung über Gemeinschaftsinhalte für SCRIPTORIUM
  AVENTURIS veröffentlicht.\par}

% ---- Inhaltsverzeichnis ----
\newcommand{\dsaInhalt}{%
  \clearpage\onecolumn
  \thispagestyle{empty}%
  {\dsaandalus\fontsize{23.5}{28.2}\selectfont\MakeUppercase{Inhalt}\par}%
  \dsaRasterluft{2}%
  \@starttoc{toc}%
  \clearpage\twocolumn}

% ---- Seite ohne Seitenzahl ----
\newenvironment{dsaSeiteOhneZahl}{%
  \clearpage\thispagestyle{empty}%
}{\clearpage}

% ---- Ganzseitige Grafik im Grafikbereich ----
\newcommand{\dsaGanzseite}[1]{%
  \clearpage\thispagestyle{empty}%
  \begin{tikzpicture}[remember picture, overlay]
    \node[anchor=north, inner sep=0]
      at ([shift={(0pt,-\dsagrafikoben)}]current page.north)
      {\dsaBildDeckend{\dsagrafikbreite}{\dsagrafikhoehe}{#1}};
  \end{tikzpicture}%
  \clearpage}

% ---- Querformat, etwa fuer einen Meisterschirm ----
% Zwei Befehle, keine Umgebung: \newgeometry darf nicht in einer Gruppe
% stehen, eine \newenvironment-Umgebung bildet aber eine.
\newcommand*{\dsaQuerAnfang}{%
  \clearpage
  \newgeometry{a4paper, landscape, margin=15mm}%
  \onecolumn\thispagestyle{empty}\dsaHintergrundAus}
\newcommand*{\dsaQuerEnde}{%
  \clearpage\restoregeometry\dsaHintergrundAn\twocolumn}
% PRUEFEN: \restoregeometry stellt \textheight wieder her; danach mit der
% Option rasterzeigen pruefen, ob die Grundlinien wieder sitzen.

%%% ==================================================================
%%% 19  Raster fuer wiederkehrende Angaben
%%% ==================================================================

\newcommand{\dsaFeld}[2]{\par\noindent\textbf{#1:} #2}

\newenvironment{dsaKurzcharakteristik}{%
  \small\setlength{\parindent}{0pt}%
}{\par}

\newenvironment{dsaWerteblock}{%
  \footnotesize\setlength{\parindent}{0pt}%
}{\par}

\newcommand{\dsaProbe}[1]{\par\noindent\textbf{#1}\par\nobreak}

\newcommand{\dsaZusammenfassung}[5]{%
  \begin{dsaWerteblock}
    \dsaFeld{Stichworte zum Abenteuer}{#1}
    \dsaFeld{Genre}{#2}
    \dsaFeld{Voraussetzungen}{#3}
    \dsaFeld{Ort}{#4}
    \dsaFeld{Zeit}{#5}
  \end{dsaWerteblock}}

% Die Rubriken sind der heutige Stand des Baukastens.
\newcommand{\dsaAnforderungen}[4]{%
  \par\noindent\textbf{Anforderungen:}\par
  \noindent\begin{tabular}{@{}p{40mm}l@{}}
    Kampftalente                  & \dsaRautenRot{#1}{18mm}\\
    Gesellschaftstalente          & \dsaRautenRot{#2}{18mm}\\
    Handwerkstalente              & \dsaRautenRot{#3}{18mm}\\
    \textbf{Lebendige Geschichte} & \dsaRautenGruen{#4}{18mm}\\
  \end{tabular}\par}

%%% ==================================================================
%%% 20  Freigestellte Grafiken und Textumfluss
%%% ==================================================================
%
% LaTeX setzt im zweispaltigen Satz erst die linke Spalte fertig, dann die
% rechte. Ein automatischer Umfluss ueber die Spaltengrenze ist damit
% ausgeschlossen — in InDesign geht es, weil dort beide Spalten gleichzeitig
% im Blick sind. Deshalb vier Bausteine, von einfach nach aufwendig.

\newcommand{\dsaBildSpalte}[2]{%
  \par\nobreak
  \noindent\parbox[t][\dsaRaster{#2}][t]{\linewidth}{%
    \centering\includegraphics[width=\linewidth]{#1}}%
  \par\nobreak}

\newcommand{\dsaBildBreit}[2]{%
  \begin{figure*}[t]
    \centering
    \parbox[t][\dsaRaster{#2}][t]{\textwidth}{%
      \centering\includegraphics[width=\textwidth]{#1}}%
  \end{figure*}}

\newcommand{\dsaBildUmflossen}[3]{%
  \begin{wrapfigure}{#1}{#3}
    \vspace*{-\dsaRaster{1}}%
    \centering\includegraphics[width=#3]{#2}%
    \vspace*{-\dsaRaster{1}}%
  \end{wrapfigure}}

% Bild ueber dem Bundsteg. Nimmt keinen Platz ein, liegt als Ueberlagerung.
\newcommand{\dsaBildBund}[3]{%
  \begin{tikzpicture}[remember picture, overlay]
    \node[anchor=north, inner sep=0]
      at ([shift={(0pt,-24mm-#3)}]current page.north)
      {\includegraphics[width=#2]{#1}};
  \end{tikzpicture}}

% \dsaUmfluss{<spalte>}{<vorlauf>}{<zeilen>}{<einzug>}
%   spalte  l = Text links, Bild rechts davon -> Zeilen rechts kuerzen
%           r = Text rechts, Bild links davon -> Zeilen links einruecken
% Das erste Argument ist die SPALTE, nicht die Seite.
\newcommand{\dsaUmfluss}[4]{%
  \begingroup
    \edef\dsa@ps{}%
    \@tempcnta=0
    \loop\ifnum\@tempcnta<#2\relax
      \edef\dsa@ps{\dsa@ps\space 0pt \the\columnwidth}%
      \advance\@tempcnta by 1
    \repeat
    \@tempdima=\dimexpr#4\relax
    \@tempdimb=\dimexpr\columnwidth-\@tempdima\relax
    \@tempcnta=0
    \loop\ifnum\@tempcnta<#3\relax
      \if l#1%
        \edef\dsa@ps{\dsa@ps\space 0pt \the\@tempdimb}%
      \else
        \edef\dsa@ps{\dsa@ps\space \the\@tempdima\space \the\@tempdimb}%
      \fi
      \advance\@tempcnta by 1
    \repeat
    \edef\dsa@ps{\dsa@ps\space 0pt \the\columnwidth}%
    \xdef\dsa@psg{\dsa@ps}%
    \xdef\dsa@psn{\the\numexpr#2+#3+1\relax}%
  \endgroup
  \parshape=\dsa@psn \dsa@psg\relax}

% \dsaUmflussKontur{<spalte>}{<vorlauf>}{<Einzugsliste, komma-getrennt>}
%
% Der Text umfliesst nicht den Bildrahmen, sondern den Freistellpfad.
% Nachgemessen an einem gesetzten Scriptorium-Abenteuer: ein Bild von
% 73,8 x 55,3 mm ueber dem Bundsteg, Rahmen bis 140,3 mm — der Text der
% rechten Spalte rueckt aber nur bis 122,8 mm ein, und zeilenweise
% unterschiedlich. Deshalb ein Einzug je Zeile.
%
% Eine gemessene Kontur, 31 Zeilen, Einzug in mm ab der Spaltenkante:
%   11.6, 12.1, 13.5, 13.4, 11.9, 16.4, 16.0, 17.9, 19.0, 20.1, 21.7,
%   22.6, 24.0, 26.0, 26.8, 26.8, 26.1, 21.3, 19.3, 18.2, 18.3, 18.0,
%   17.3, 16.7, 14.6, 14.4, 17.1, 23.1, 22.4
\newcommand{\dsaUmflussKontur}[3]{%
  \begingroup
    \edef\dsa@ps{}%
    \@tempcnta=0
    \loop\ifnum\@tempcnta<#2\relax
      \edef\dsa@ps{\dsa@ps\space 0pt \the\columnwidth}%
      \advance\@tempcnta by 1
    \repeat
    \@tempcntb=\numexpr#2\relax
    \@for\dsa@e:=#3\do{%
      \@tempdima=\dimexpr\dsa@e\relax
      \@tempdimb=\dimexpr\columnwidth-\@tempdima\relax
      \if l#1%
        \edef\dsa@ps{\dsa@ps\space 0pt \the\@tempdimb}%
      \else
        \edef\dsa@ps{\dsa@ps\space \the\@tempdima\space \the\@tempdimb}%
      \fi
      \advance\@tempcntb by 1
    }%
    \edef\dsa@ps{\dsa@ps\space 0pt \the\columnwidth}%
    \advance\@tempcntb by 1
    \xdef\dsa@psg{\dsa@ps}%
    \xdef\dsa@psn{\the\@tempcntb}%
  \endgroup
  \parshape=\dsa@psn \dsa@psg\relax}
% PRUEFEN: Beide Befehle bauen die \parshape-Liste selbst auf. \parshape
% braucht die Zeilenzahl und danach genau doppelt so viele Laengen; ist die
% Liste falsch, bricht der Lauf mit unverstaendlicher Meldung ab. Mit kleinen
% Werten testen, etwa \dsaUmfluss{l}{2}{4}{25mm}.

\endinput

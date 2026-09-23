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
%%% Zeilen mit  % OFFEN:  nennen einen Wert, fuer den der Baukasten keine
%%% Quelle hergibt. Es sind vier, und sie sind nicht ungeprueft — es gibt
%%% nichts, woran man sie messen koennte. Wer eine Quelle findet, entfernt
%%% die Marke und traegt den Wert in doku/MASSE.md ein. Was bisher gemessen
%%% wurde, steht in doku/PRUEFPLAN.md.

\NeedsTeXFormat{LaTeX2e}
\ProvidesClass{dsa5latex}[2026/09/07 v2.0 DSA5-Satz nach Scriptorium Aventuris v4]

%%% ==================================================================
%%% 1  Optionen
%%% ==================================================================

\newif\ifdsa@raster        \dsa@rastertrue
\newif\ifdsa@rasterzeigen  \dsa@rasterzeigenfalse
\newif\ifdsa@entwurf       \dsa@entwurffalse
% Die Seitenhintergruende sind die groessten Grafiken im Satz, 7 bis 8 MB je
% Seite. Wer am Umschlag oder am Text arbeitet, braucht sie nicht, und der
% Lauf wird deutlich kuerzer.
\newif\ifdsa@ohnehintergrund \dsa@ohnehintergrundfalse

\DeclareOption{raster}{\dsa@rastertrue}
\DeclareOption{ohneraster}{\dsa@rasterfalse}
\DeclareOption{rasterzeigen}{\dsa@rasterzeigentrue}
\DeclareOption{entwurf}{\dsa@entwurftrue}
\DeclareOption{ohnehintergrund}{\dsa@ohnehintergrundtrue}
\DeclareOption*{\PassOptionsToClass{\CurrentOption}{article}}
\ProcessOptions\relax

% Basis ist article, nicht book: book bringt eine Kapitelmaschinerie mit, die
% hier vollstaendig ersetzt wuerde. twoside und twocolumn kommen von hier,
% damit \twocolumn[...] und figure* ohne Umstaende funktionieren.
\LoadClass[10pt,a4paper,twoside,twocolumn]{article}
% Die Grundschrift wird unten in bp neu gesetzt; die 10pt hier sind nur die
% Grundlage fuer die Groessenbefehle von article.

%%% ==================================================================
%%% 2  Pakete
%%% ==================================================================

\RequirePackage{geometry}
\RequirePackage{graphicx}
\RequirePackage{xcolor}
\RequirePackage{fontspec}
\RequirePackage{polyglossia}
\RequirePackage{tikz}
\usetikzlibrary{calc,shadows.blur}
\RequirePackage[most]{tcolorbox}
\RequirePackage{eso-pic}
\RequirePackage{fancyhdr}
\RequirePackage{enumitem}
\RequirePackage{wrapfig}
\RequirePackage[auto]{contour}
\RequirePackage{changepage}
% Fuer das zweispaltige Inhaltsverzeichnis. \twocolumn taugt dafuer nicht:
% es braeuchte einen Seitenwechsel, und die Ueberschrift soll ueber beiden
% Spalten stehen.
\RequirePackage{multicol}
\RequirePackage{intcalc}
\RequirePackage{array}
\RequirePackage{etoolbox}
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
% spelling=new laeuft. Geprueft an allen vier Beispieldokumenten mit
% polyglossia aus TeX Live 2026; faellt es auf einer aelteren Installation
% aus, tut es \setdefaultlanguage{german} auch — die Trennmuster sind dann
% trotzdem deutsch.

%%% ==================================================================
%%% 4  Grafikpfad
%%% ==================================================================
%
% Alle Grafiken liegen in grafiken/ und werden von
% werkzeuge/aufbereiten.py dort angelegt. Namen ohne Leerzeichen und
% Umlaute, weil LaTeX mit beidem schlecht umgeht.

\newcommand*{\dsagrafik}[1]{grafiken/#1}

% Gesucht wird in beiden Ordnern: neben dem Dokument und eine Ebene hoeher.
% So laeuft ein Satz auch aus einem Unterordner heraus, etwa beispiel/.
\graphicspath{{./}{../}}

% Die Endungsreihenfolge: JPEG vor PNG.
%
% Grafiken werden ohne Endung angesprochen, graphicx probiert sie der Reihe
% nach — und zwar fuer jede Endung alle Suchpfade. Wenn ein Projekt seinen
% eigenen Ordner grafiken/ hat und TEXINPUTS zusaetzlich auf den Ordner der
% Klasse zeigt, gewinnt so ein altes PNG im einen Ordner gegen das neue JPEG
% im anderen. Da die Vollseitengrafiken absichtlich als JPEG vorliegen, wird
% diese Reihenfolge umgedreht.
\DeclareGraphicsExtensions{.jpg,.jpeg,.png,.pdf}

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

% Der Ordner mit den Schriften: erst neben dem Dokument suchen, dann eine
% Ebene hoeher. fontspec nimmt nur einen Pfad, deshalb wird er hier bestimmt,
% bevor die erste Schrift geladen wird.
%
% Beide Pfade beginnen mit ./ — ohne den Punkt sucht kpathsea den Namen in
% TEXINPUTS mit. Wer die Klasse mit TEXINPUTS=.. aus einem Unterordner baut,
% bekaeme dann schriften/GenBasR.ttf ueber den Elternpfad gemeldet: gefunden
% waere die Datei, aber fontspec bekaeme mit Path=schriften/ einen Pfad, den
% es vom Arbeitsverzeichnis aus nicht gibt, und der Lauf endete mit "not
% loadable". Ein fuehrendes ./ schaltet die Suche ab und fragt genau das
% Arbeitsverzeichnis.
\IfFileExists{./schriften/GenBasR.ttf}
  {\newcommand*{\dsa@schriften}{./schriften/}}
  {\IfFileExists{./../schriften/GenBasR.ttf}
     {\newcommand*{\dsa@schriften}{../schriften/}}
     {\newcommand*{\dsa@schriften}{./schriften/}%
      \ClassWarning{dsa5latex}{Der Ordner schriften/ ist weder neben dem
        Dokument noch eine Ebene hoeher zu finden. Erzeugen mit
        werkzeuge/aufbereiten.py}}}

\setmainfont{GenBasR}[
  Path           = \dsa@schriften,
  Extension      = .ttf,
  BoldFont       = GenBasB,
  ItalicFont     = GenBasI,
  BoldItalicFont = GenBasBI ]

% Der Fliesstext: 10 bp auf 12 bp. Der Baukasten nennt „10 pt", und das sind
% InDesign-Punkte, also bp. In TeX-Punkten waeren es 10,04 pt — der
% Unterschied ist beim Grad kaum zu sehen, beim Zeilenabstand aber
% entscheidend, weil er sich ueber die Spalte summiert.
\newcommand*{\dsagrundgrad}{10}
\newcommand*{\dsagrunddurchschuss}{12}

% \normalsize selbst umdefinieren, nicht nur die Schrift im
% \AtBeginDocument einstellen: \normalsize ist der Haken, den LaTeX fuer
% die Grundschrift vorsieht, und alles, was ihn zieht, holte sonst die
% 10 pt auf 12 pt der Basisklasse zurueck.
%
% Gemessen hatte \newgeometry genau das getan. Ab \dsaQuerAnfang lief der
% Satz mit 12,0 statt 12,045 pt Durchschuss -- und nach \dsaQuerEnde
% weiter, also auf jeder Seite nach einem Querformat. Ueber 59 Zeilen sind
% das 2,6 bp Drift.
\renewcommand{\normalsize}{%
  \@setfontsize\normalsize{\dsagrundgrad bp}{\dsagrunddurchschuss bp}%
  \abovedisplayskip\z@ \belowdisplayskip\z@
  \abovedisplayshortskip\z@ \belowdisplayshortskip\z@}
\AtBeginDocument{\normalsize}

% Die Klasse laedt kein Mathematik-Schriftpaket (siehe \dsaFormel). LaTeX
% richtet trotzdem bei jedem \selectfont die drei Mathematik-Groessen ein
% und leitet sie mit 0,7 und 0,5 aus der Grundgroesse ab. Aus 9 bp werden
% so 6,32 und 4,52 pt, und die gibt es in Computer Modern nicht: "Font
% shape OT1/cmr/m/n in size <4.51686> not available", dreimal je Groesse.
% Am Satz aendert das nichts, weil im Heft keine Formel steht. Die Stufen
% werden deshalb ausdruecklich auf vorhandene gelegt.
\DeclareMathSizes{9bp}{9bp}{7bp}{5bp}
\DeclareMathSizes{10bp}{10bp}{7bp}{5bp}
\DeclareMathSizes{12bp}{12bp}{9bp}{7bp}
\DeclareMathSizes{14bp}{14bp}{10bp}{7bp}

% Andalus hat nur einen Schnitt. Ohne AutoFakeBold meldet der Lauf
% „Font shape TU/andlso(0)/b/n undefined" und faellt still auf den normalen
% zurueck — der Baukasten verlangt fuer Kapitel und Covertitel aber fett.
% Also nachbilden lassen.
\newfontfamily{\dsaandalus}{andlso}[
  Path          = \dsa@schriften,
  Extension     = .ttf,
  AutoFakeBold  = 1.5,
  AutoFakeSlant = 0.2 ]

% Kapitaelchen. Keine der beiden Schriften hat das OpenType-Feature smcp —
% nachgesehen in allen fuenf Dateien. \textsc tut damit nichts, still und
% ohne Warnung. Deshalb nachgebildet: Versalien auf 82 Prozent.
\newlength{\dsa@kapgrad}
\DeclareRobustCommand*{\dsaKapitaelchen}[1]{%
  \setlength{\dsa@kapgrad}{0.82\dimexpr\f@size pt\relax}%
  % \f@size zaehlt in pt, \dsa@kapgrad ist deshalb eine pt-Laenge — richtig
  % so, denn 82 Prozent des aktuellen Grades sind unabhaengig von der Einheit.
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
% Die drei Grauwerte der Tabelle sind im IDML Tonwerte von „Black", und
% „Black" ist dort CMYK 0/0/0/100. Ein Tonwert davon kommt beim Export nicht
% als 100-x Prozent Weiss heraus, sondern geht durch das Farbprofil. Deshalb
% steht hier nicht der gerechnete, sondern der am Baukasten-PDF gemessene
% Wert — das ist die Farbe, die der Leser sieht:
%
%   Tonwert  gerechnet  gemessen (Seite 8)
%   10 %     #E6E6E6    #ECECEC   Kopf- und Anmerkungszeile
%   25 %     #BFBFBF    #D0D0D0   Linie unter jeder Wertezeile
%   60 %     #666666    #878785   Linie ueber und unter der Titelzeile
\definecolor{dsatabellengrau}{HTML}{ECECEC}      % 10 % Schwarz
\definecolor{dsatabellenlinie}{HTML}{D0D0D0}     % 25 % Schwarz
\definecolor{dsatabellenkopflinie}{HTML}{878785} % 60 % Schwarz
\definecolor{dsazitat}{HTML}{404040}

%%% ==================================================================
% ---- Zur Einheit ----
%
% Alle Masse dieser Klasse, die aus dem Baukasten kommen, sind in bp
% angegeben: PostScript-Punkte, 1/72 Zoll. So rechnet InDesign, und so
% rechnet auch die Umrechnung von Pixeln (300 Pixel je Zoll geteilt durch 72).
%
% TeX rechnet ohne Einheit in pt, und ein pt ist 1/72,27 Zoll — 0,4 Prozent
% kleiner. Beim Schriftgrad merkt man das nicht, beim Zeilenabstand schon:
% ein Raster aus 12 pt statt 12 bp laeuft auf einer Spalte von 59 Zeilen um
% 2,6 bp aus dem Tritt, fast einen Millimeter. Am gesetzten Ergebnis war das
% als stetig wachsende Abweichung zu sehen, 0,03 pt je Zeile.
%
% Wer hier ein Mass ergaenzt: steht es im Baukasten, in einer IDML oder ist
% es aus Pixeln gerechnet, dann ist es bp.

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
  textheight=708bp,
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

% 12 bp, nicht 12 pt. Der Baukasten ist in InDesign gesetzt, und dort ist
% ein Punkt 1/72 Zoll — ein TeX-Punkt ist 1/72,27 Zoll und damit 0,4 Prozent
% kleiner. Auf eine Spalte von 59 Zeilen summiert sich das zu fast einem
% Millimeter, und die Grundlinien beider Spalten laufen auseinander.
% Zwei Zustaende fuer \lineskip.
%
% Im Rastersatz gilt: immer den Durchschuss nehmen, nie zusaetzlichen Raum
% einfuegen. Nur so haelt eine Ueberschrift, die hoeher ist als der
% Durchschuss, das Raster.
%
% Vor einer hohen Box gilt das Gegenteil: dort muss TeX den Raum vergeben,
% den die Box braucht. Sonst bekommt eine Tabelle von 84 bp Hoehe 12 bp und
% laeuft ueber den Text darunter.
\newcommand*{\dsa@lineskipnormal}{%
  \setlength{\lineskip}{1pt}%
  \setlength{\lineskiplimit}{0pt}}
\newcommand*{\dsa@lineskipraster}{%
  \setlength{\lineskip}{0pt}%
  \setlength{\lineskiplimit}{-\maxdimen}}

\newlength{\dsaRastermass}    \setlength{\dsaRastermass}{12bp}
\newcommand*{\dsaRaster}[1]{#1\dsaRastermass}
\newcommand*{\dsaRasterluft}[1]{\vspace*{\dsaRaster{#1}}}

\ifdsa@raster
  % Die erste Grundlinie der Seite muss auf einer Rasterlinie sitzen, sonst
  % liegt die ganze Seite daneben. Der Satzspiegel beginnt bei 24 mm =
  % 68,03 pt, das Raster liegt auf 36 + 12k pt. Die erste Linie darunter ist
  % 84 pt, also 29,63 mm — und genau dort stehen im Musterbogen des
  % Baukastens die Seitenueberschriften, auf jeder Seite.
  %
  %   \topskip = 84 bp - 24 mm
  \setlength{\topskip}{\dimexpr 84bp-24mm\relax}
  % Gemerkt, damit \dsaQuerEnde den Wert zurueckstellen kann.
  \newlength{\dsa@topskip}\setlength{\dsa@topskip}{\topskip}
  \setlength{\parskip}{0pt}
  % Kein Erstzeileneinzug. Die Absatzformate der IDML haben keinen: das
  % Fliesstextformat traegt kein FirstLineIndent, und die einzigen Formate mit
  % einem haben einen negativen — die haengenden Einzuege von Aufzaehlung
  % (-17,01 pt) und Werteabsatz (-8,50 pt).
  %
  % Der Einzug hatte ausserdem alle Kaesten verschoben: eine tcolorbox ist ein
  % Absatz und wurde um 1 em eingerueckt. Gemessen waren es 3,58 mm bei jedem
  % der dreizehn Kaesten.
  %
  % Absaetze trennt der Baukasten weder durch Einzug noch durch Abstand —
  % auch SpaceBefore und SpaceAfter fehlen in seinen Formaten. Getrennt wird
  % durch Ueberschriften, Aufzaehlungen und Kaesten. Wer Luft braucht, nimmt
  % \dsaRasterluft{1}; das haelt das Grundlinienraster.
  \setlength{\parindent}{0pt}
  % \lineskip bleibt hier auf den Standardwerten. Es waere verlockend, den
  % Grenzwert global auf -\maxdimen zu setzen — dann haelt TeX immer den
  % Durchschuss, und Ueberschriften verlassen das Raster nicht. Nur gilt das
  % auch fuer jede hohe Box: eine Tabelle von 84 bp Hoehe bekaeme 12 bp Raum
  % und liefe ueber den Text darunter. Gemessen und im Abzug gesehen.
  %
  % Die Regel gilt deshalb nur dort, wo sie gebraucht wird: in den
  % Ueberschriften, ueber \dsa@lineskipraster in einer Gruppe.
  % \raggedbottom und nicht \flushbottom. Das Raster hat keine dehnbare
  % Glue zwischen den Zeilen -- \flushbottom findet nichts zum Strecken
  % und meldet stattdessen jede Seite, die nicht randvoll ist: 32 mal
  % "Underfull \vbox has occurred while \output is active". Am Satz
  % aendert sich nichts, die Zeilen liegen in beiden Faellen auf dem
  % Raster; \raggedbottom sagt nur ausdruecklich, dass der Rest der Seite
  % unten bleibt.
  \raggedbottom
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
% Der Vergleich laeuft ueber zwei pgfmath-Makros, die als Laengen in pt
% verglichen werden. Das haelt: \dsaBildDeckend steht in beiden Umschlaegen
% und auf der Rueckseite jedes Beispieldokuments.
%
% OFFEN: Der Beschnitt ist mittig. Bei einem Portrait sitzt der Kopf oft
% oben; dann braucht es einen Versatz. Ein Sollmass dafuer gibt es nicht —
% der Baukasten zeigt keinen beschnittenen Portraetausschnitt. Wer einen
% braucht, nimmt \dsaBildForm oder schneidet mit werkzeuge/freistellen.py
% vor, das --x und --y kennt.

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
% Fadings sind Transparenzgruppen und brauchen einen Treiber, der sie kann.
% XeLaTeX ueber xdvipdfmx kann sie: der Covertitel legt je Zeile ein eigenes
% Fading an, und beide Umschlaege bauen. Nur \dsaBildMaskiert selbst steht
% in keinem Beispieldokument und ist damit als einziges ungeprueft.

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
% Die Nummer der ausgegebenen Seite steht im Haken nicht in \value{page} —
% der LaTeX-Zaehler ist dort noch nicht gesetzt —, sondern in \count0, dem
% Register, das TeX beim Ausschiessen fuehrt. Mit \value{page} war die
% Variante auf jeder Seite 0 und die Lage immer die linke.
\newcommand*{\dsa@bgseite}{\the\count0}
% Die Folge ist 0,0,1,1,2,2 und dann wieder von vorn: je zwei Seiten eine
% Variante, beginnend mit der ersten. Deshalb wird (Seite - 1) geteilt — mit
% der Seite selbst waere die Folge 0,1,1,2,2,0 und die erste Variante kaeme
% nur einmal vor.
%
% Drei Varianten, nicht vier: die vierte des Baukastens hat in der unteren
% Aussenecke kein Feld fuer die Seitenzahl. Dort steht sie auf blankem
% Pergament, waehrend sie in den ersten drei in einer dunklen Kartusche
% sitzt. Wer sie doch verwenden will, setzt die 3 hier auf 4.
\newcommand*{\dsa@bgvarianten}{3}
% Die vierte Variante hat kein Feld fuer die Zahl. Sie ist die richtige fuer
% Seiten, die keine tragen -- Impressum und Inhalt. \dsaHintergrundOhneFeld
% waehlt sie fuer die laufende Seite; \dsa@bgfest ist leer, solange die
% Folge gilt.
\newcommand*{\dsa@bgfest}{}
\newcommand*{\dsaHintergrundOhneFeld}{%
  \gdef\dsa@bgfest{3}%
  \thispagestyle{empty}%
  % Nach der Seite gilt wieder die Folge.
  \AddToHookNext{shipout/after}{\gdef\dsa@bgfest{}}}
\newcommand*{\dsa@bgvariante}{%
  \ifx\dsa@bgfest\@empty
    \intcalcMod{\intcalcDiv{\numexpr\dsa@bgseite-1\relax}{2}}{\dsa@bgvarianten}%
  \else
    \dsa@bgfest
  \fi}

\AddToShipoutPictureBG{%
  \ifdsa@ohnehintergrund\else
  \ifdsa@bgaus\else
    \begin{tikzpicture}[remember picture, overlay]
      \ifodd\count0
        \node[anchor=north east, inner sep=0]
          at ([shift={(\dsabeschnitt,\dsabeschnitt)}]current page.north east)
          {\includegraphics[width=213mm,height=303mm]{\dsagrafik{seite-rechts-\dsa@bgvariante}}};
      \else
        \node[anchor=north west, inner sep=0]
          at ([shift={(-\dsabeschnitt,\dsabeschnitt)}]current page.north west)
          {\includegraphics[width=213mm,height=303mm]{\dsagrafik{seite-links-\dsa@bgvariante}}};
      \fi
    \end{tikzpicture}%
  \fi\fi}
% Am Abzug geprueft: der Anker an der Aussenkante trifft die Zierleisten,
% und die Folge ist 0,0,1,1,2,2 und wieder von vorn.

%%% ==================================================================
%%% 11  Fusszeile
%%% ==================================================================

\pagestyle{fancy}
\fancyhf{}
\renewcommand{\headrulewidth}{0pt}
\renewcommand{\footrulewidth}{0pt}

% Die Zahl gehoert in das Ornament am unteren Aussenrand des
% Seitenhintergrunds. Gemessen am Musterbogen des Baukastens: Andalus 13 pt,
% Grundlinie 5,9 mm ueber der unteren Papierkante, Mitte 18,4 mm von der
% Aussenkante. Die Grundlinie stammt aus der Textmatrix; die Unterkante der
% Zeichenbox liegt 1,9 mm tiefer und ist nicht das gesuchte Mass. Die Zeichenformate der IDML nennen fuer die Grundeinstellung
% ebenfalls Andalus 13 pt.
%
% Aussen oder innen: im Musterbogen traegt die PDF-Seite 3 die Zahl „2", das
% Deckblatt zaehlt also nicht mit. PDF-Seite 3 ist damit die gedruckte
% Seite 2, eine linke Seite, und dort steht die Zahl links — aussen.
%
% Gesetzt als Knoten an der Papierkante, nicht ueber die Spalten von
% fancyhdr: die sitzen im Satzspiegel und wissen nichts vom Anschnitt.
\newlength{\dsaseitenzahlaussen}\setlength{\dsaseitenzahlaussen}{18.4mm}
\newlength{\dsaseitenzahlunten} \setlength{\dsaseitenzahlunten}{5.9mm}
\newcommand*{\dsaseitenzahlgrad}{13}
\newlength{\dsaseitenzahlkontur}\setlength{\dsaseitenzahlkontur}{0.6pt}

% #1 die Ecke, von der aus gemessen wird
% #2 Vorzeichen der Richtung nach innen
\newcommand{\dsa@seitenzahlan}[2]{%
  \begin{tikzpicture}[remember picture, overlay]
    \node[anchor=base, inner sep=0]
      at ([shift={(#2\dsaseitenzahlaussen,\dsaseitenzahlunten)}]#1)
      {\dsaandalus\fontsize{\dsaseitenzahlgrad bp}{\dsaseitenzahlgrad bp}%
       \selectfont\contourlength{\dsaseitenzahlkontur}%
       \contour{black}{\textcolor{white}{\thepage}}};
  \end{tikzpicture}}

% Der Kolumnentitel neben der Zahl. Gemessen an einer gesetzten
% Veroeffentlichung des Verlags: Andalus 14 bp, schwarz und ohne Kontur, auf
% derselben Grundlinie wie die Zahl. Der Text ist der Abenteuertitel, ein
% Gedankenstrich und der Kapitelname.
%
% Die Lage: der Titel schliesst mit dem Satzspiegel ab, auf beiden Seiten
% 24 mm von der Aussenkante -- rechts rechtsbuendig bei 186 mm, links
% linksbuendig bei 24 mm. Damit steht er bündig unter dem Textblock, und der
% Abstand zur Zahl ist auf beiden Seiten gleich: ihre Mitte sitzt 18,4 mm
% von der Kante, ihr innerer Rand also rund 4 mm vor dem Titel.
%
% Im Vorbild ist die Lage nicht spiegelbildlich -- rechts 24,29 mm, links
% 40,35 mm, beides stabil ueber mehrere Seiten. Am Abzug gesehen ist das
% schief, und der dortige Satzspiegel ist ohnehin ein anderer als unserer.
% Wer die Vorbildlage haben will, setzt die linke Laenge auf 40,35 mm.
\newlength{\dsakolumneaussenrechts}
\setlength{\dsakolumneaussenrechts}{24mm}
\newlength{\dsakolumneaussenlinks}
\setlength{\dsakolumneaussenlinks}{24mm}
\newcommand*{\dsakolumnegrad}{14}

% Der Abenteuertitel, in der Praeambel zu setzen. Ohne ihn bleibt der
% Kolumnentitel der Kapitelname allein; ohne Kapitel bleibt er ganz leer.
\newcommand*{\dsa@abenteuertitel}{}
\newcommand*{\dsaAbenteuertitel}[1]{\renewcommand*{\dsa@abenteuertitel}{#1}}

% Der Kapitelname kommt ueber die Marken von LaTeX, damit jede Seite den
% Namen ihres Kapitels traegt und nicht den des naechsten.
% Der Leertest auf \leftmark muss die Expansion pruefen: \ifx vergleicht
% Makros, und \leftmark ist auch dann ein anderes Makro als \@empty, wenn
% es sich zu nichts expandiert. Vor dem ersten Kapitel stand sonst der
% Trennstrich ohne Namen. \detokenize taugt dafuer nicht -- es
% verhindert die weitere Expansion seines Arguments, und \leftmark
% braucht mehr als einen Schritt.
\newcommand*{\dsa@kolumnetext}{%
  \begingroup
    \protected@edef\dsa@kolumnemarke{\leftmark}%
    % Der Titel muss fuer den Vergleich genauso weit expandiert sein wie
    % die Marke, sonst sind zwei gleiche Namen fuer \ifx verschiedene
    % Makros.
    \protected@edef\dsa@kolumnetitel{\dsa@abenteuertitel}%
    \ifx\dsa@kolumnemarke\@empty
      \dsa@abenteuertitel
    \else
      \ifx\dsa@kolumnetitel\@empty
        \leftmark
      \else
        \ifx\dsa@kolumnemarke\dsa@kolumnetitel
          % Heisst das einzige Kapitel wie das Abenteuer -- bei einem Solo
          % und bei jedem einkapitligen Heft der Normalfall --, stuende der
          % Name sonst zweimal nebeneinander in der Fusszeile.
          \dsa@abenteuertitel
        \else
          \dsa@abenteuertitel\,--\,\leftmark
        \fi
      \fi
    \fi
  \endgroup}

% #1 die Ecke, #2 Vorzeichen nach innen, #3 der Abstand, #4 der Anker
\newcommand{\dsa@kolumnean}[4]{%
  \begin{tikzpicture}[remember picture, overlay]
    \node[anchor=#4, inner sep=0]
      at ([shift={(#2#3,\dsaseitenzahlunten)}]#1)
      {\dsaandalus\fontsize{\dsakolumnegrad bp}{\dsakolumnegrad bp}%
       \selectfont\dsa@kolumnetext};
  \end{tikzpicture}}

\fancyfoot[LE]{%
  \dsa@seitenzahlan{current page.south west}{}%
  \dsa@kolumnean{current page.south west}{}{\dsakolumneaussenlinks}{base west}}
\fancyfoot[RO]{%
  \dsa@seitenzahlan{current page.south east}{-}%
  \dsa@kolumnean{current page.south east}{-}{\dsakolumneaussenrechts}{base east}}

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
% Das Banner sitzt nicht an der Papierkante, sondern 11,32 mm darunter — so
% liegt es im Musterbogen (Grafik bei y 11,32 mm, 210,06 x 43,18 mm gross).
% Der Titel darin bleibt davon unberuehrt, seine Grundlinie ist als eigenes
% Mass gesetzt.
\newlength{\dsabannerversatz} \setlength{\dsabannerversatz}{11.32mm}
% Der linke Rand des Satzspiegels: auf einer rechten Seite ist das der innere
% (20 mm), auf einer linken der aeussere (24 mm). Der Kapiteltitel ist
% linksbuendig im Satzspiegel und braucht deshalb dieses Mass.
\newlength{\dsa@linkerrand}
\newcommand*{\dsa@linkerrandsetzen}{%
  \ifodd\value{page}\setlength{\dsa@linkerrand}{20mm}%
  \else\setlength{\dsa@linkerrand}{24mm}\fi}
% Der Baukasten setzt das Banner an die Papierkante. In gesetzten
% Scriptorium-Abenteuern sitzt es 16 bis 25 mm darunter — als Laenge
% gehalten, damit es sich ohne Eingriff verschieben laesst.

% Die Lage des Titels, gemessen am Musterbogen: erste Grundlinie 33,41 mm
% unter der Papieroberkante, Zeilenabstand 28,2 pt, linksbuendig ab dem
% inneren Rand. Der Textrahmen im Banner ist laut IDML 166,25 mm breit und
% 20,53 mm von links eingesetzt — also genau der Satzspiegel.
\newlength{\dsabannertitelunten}\setlength{\dsabannertitelunten}{33.41mm}

% Nur die Knoten, ohne eigene tikzpicture: der Vorspann einer Kapitelseite
% zeichnet Rahmen und Banner in EINEM Bild. Zwei Bilder mit „remember
% picture" im selben \twocolumn-Vorspann vertragen sich nicht -- gemessen
% landete der Bannertitel dann bei -239,61 mm, weit ueber der Seite.
\newcommand*{\dsa@bannerknoten}[1]{%
  \node[anchor=north, inner sep=0]
    at ([shift={(0pt,-\dsabannerversatz)}]current page.north)
    {\includegraphics[width=210.1mm]{\dsagrafik{kapitelbanner}}};
  % anchor=base west: die Grundlinie sitzt auf dem gemessenen Mass, der
  % Anfang der Zeile am inneren Rand. Kein text width und kein align —
  % der Titel ist linksbuendig.
  \node[anchor=base west, inner sep=0]
    at ([shift={(\dsa@linkerrand,-\dsabannertitelunten)}]%
        current page.north west)
    {\dsaandalus\fontsize{\dsakapitelgrad bp}{28.2bp}\selectfont
     \MakeUppercase{#1}};}

\newcommand*{\dsa@bannerblock}[1]{%
  \dsa@linkerrandsetzen
  \begin{tikzpicture}[remember picture, overlay]
    \dsa@bannerknoten{#1}%
  \end{tikzpicture}%
  \dsaRasterluft{\dsabannerluft}}

% Der Vorspann mit Rahmen: erst der Rahmen, dann das Banner darueber.
\newcommand*{\dsa@bannerblockmitrahmen}[2]{%
  \dsa@linkerrandsetzen
  \begin{tikzpicture}[remember picture, overlay]
    \dsa@rahmenknoten{#1}%
    \dsa@bannerknoten{#2}%
  \end{tikzpicture}%
  \dsaRasterluft{\dsabannerluft}}
% Der Kapiteltitel misst 31,73 bp, nicht 23,5. Beides steht in der IDML und
% beides stimmt: das Absatzformat „Kapitel-Ueberschrift" nennt PointSize
% 23,5 und dazu HorizontalScale und VerticalScale von je 135. 23,5 mal 1,35
% sind 31,725 — und genau 31,73 pt liest man aus dem Musterbogen und aus
% zwei gesetzten Abenteuern (US25324, US25326), dort an acht
% Kapitelanfaengen ohne eine Abweichung. Der Durchschuss bleibt 28,2 pt;
% zweizeilige Titel liegen dort auf 94,71 und 122,91.
%
% Kein „Kapitel N:" davor. Die acht Kapitelanfaenge der beiden Abenteuer
% tragen nur den Titel: EINLEITUNG, DER GESTOHLENE VERTRAG, RECHT UND
% ORDNUNG, KETTEN FUER DIE EWIGKEIT, ANHANG. Die Nummer steht nirgends.

% 23,5 pt mal 135 Prozent Skalierung der IDML.
\newcommand*{\dsakapitelgrad}{31.73}

% Der Raum, den der Bannerblock unter sich freilaesst. Sieben
% Rastereinheiten: in beiden gesetzten Abenteuern beginnt der Text der
% Kapitelseite auf y 168,00 pt, und 84 + 7 mal 12 sind 168. Das gilt fuer
% ein- wie fuer zweizeilige Titel — die zweite Titelzeile liegt auf 122,91
% und bleibt mit ihrer Unterlaenge deutlich darueber.
\newcommand*{\dsabannerluft}{7}

% \dsakapitel[<Bild>]{<Titel>}
% Reihenfolge: erst \twocolumn, also neue Seite plus Banner, dann das
% Kapitelbild — sonst landet das Bild auf der Vorseite.
% Zwei Arten von Kapitelseiten:
%
%   \dsakapitel{Titel}              ohne Rahmen, Text ueber beide Spalten
%   \dsakapitelbild[<Bild>]{Titel}  mit Bildrahmen zur Aussenseite; ohne
%                                   Argument bleibt die Pergamentflaeche als
%                                   Platzhalter stehen
%
% Auf der Rahmenseite ist die Aussenhaelfte belegt. Der Text muss deshalb in
% die innere Spalte passen und die Seite mit \dsaKapitelseiteEnde beendet
% werden, sonst laeuft er hinter den Rahmen -- eine Grenze von LaTeX, nicht
% der Klasse.
\newcommand*{\dsa@kapitelmarken}[1]{%
  % In die Marken, damit der Kolumnentitel in der Fusszeile den Namen des
  % Kapitels kennt, auf dessen Seite er steht.
  \markboth{#1}{#1}%
  % \quad ist im PDF-Gliederungseintrag nicht erlaubt: hyperref meldet
  % "Token not allowed in a PDF string" und ersetzt es durch ein
  % Leerzeichen. Also gleich beides sagen -- Abstand fuers Verzeichnis,
  % Leerzeichen fuer die Gliederung.
  % Ohne eigenen Anker zeigen Kapitel und Unterkapitel auf dieselbe
  % Stelle, und hyperref meldet "The anchor of a bookmark and its parent's
  % must not be the same".
  \phantomsection
  \addcontentsline{toc}{section}{%
    \texorpdfstring{\thedsakapitel\quad}{\thedsakapitel\space}#1}}

% Ein Kapitel faengt immer auf einer rechten Seite an, wie im gedruckten
% Heft. Steht die naechste Seite links, kommt eine Leerseite davor: mit
% Hintergrund, aber ohne Seitenzahlfeld und ohne Kolumnentitel.
%
% Das ist nicht nur Buchbindersitte, sondern Bedingung fuer den
% Kapitelrahmen. Er sitzt auf der AUSSENhaelfte der Seite -- rechts auf
% einer rechten, links auf einer linken. Faengt ein Kapitel links an,
% wandert er in den Bund.
%
% Nach \clearpage traegt der Seitenzaehler schon die Nummer der
% kommenden Seite; die Parittaetspruefung gilt also ihr und nicht der
% eben ausgegebenen.
\newcommand*{\dsa@aufrechteSeite}{%
  \clearpage
  \ifodd\value{page}\else
    \dsaHintergrundOhneFeld
    \null
    \clearpage
  \fi}

\newcommand{\dsakapitel}[2][]{%
  % Ein Bild als optionales Argument gilt weiter, damit bestehende
  % Dokumente laufen -- es fuehrt auf die zweite Art.
  \if\relax\detokenize{#1}\relax
    \dsa@aufrechteSeite
    \stepcounter{dsakapitel}%
    \twocolumn[\dsa@bannerblock{#2}]%
    \dsa@kapitelmarken{#2}%
  \else
    \dsakapitelbild[#1]{#2}%
  \fi}

\newcommand{\dsakapitelbild}[2][]{%
  \dsa@aufrechteSeite
  \stepcounter{dsakapitel}%
  \twocolumn[\dsa@bannerblockmitrahmen{#1}{#2}]%
  \dsa@kapitelmarken{#2}}

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
% OFFEN: geschaetzt. Der Baukasten zeigt den Kapitelanfang nur mit der
% Beispielgrafik randlos auf der Pergamentflaeche, nicht eingerueckt — eine
% Sollbreite fuer den sichtbaren Rand gibt er nicht her. Wer eine gesetzte
% Kapitelseite mit Bild zur Hand hat, misst nach und traegt es in MASSE.md
% ein.

% Der Zeichner fuer beide Wege. #1 ist der Bildpfad oder leer -- ohne Bild
% bleibt die Pergamentflaeche als Platzhalter stehen.
%
% Gezeichnet wird im Vorspann der Seite, vor dem Banner: im Verlagslayout
% liegt das Banner ueber dem Bild. Der Umweg ueber den Seitenhintergrund von
% eso-pic hat die Fusszeile verschluckt.
% Der Zierrahmen des Kapitelanfangs, gemessen bei 300 ppi an
% kapitelstart-rahmen.png (109,22 x 299,97 mm):
%
%   linker Schenkel    3,13 .. 6,60 mm
%   rechter Schenkel  93,13 .. 97,03 mm
%   Kante oben         0,00 .. 0,17 mm
%   Ornament unten   267,80 .. 286,51 mm
%   Deckung insgesamt  0,51 .. 97,11 mm waagerecht, 0 .. 286,60 senkrecht
%
% Der Rahmen liegt ganz auf der Seite und laesst den Seitenhintergrund in
% Ruhe: er sitzt im Satzspiegel der Aussenhaelfte, waagerecht eine
% Spaltenbreite (80,5 mm), senkrecht von der Satzspiegeloberkante an.
%
% Dafuer ist die Datei auf 80,50 / 96,60 = 0,8333 verkleinert, also auf
% 91,02 x 249,97 mm. Ihre Deckung ist dann 80,50 x 238,83 mm und passt in
% die 249,80 mm Satzspiegelhoehe. Alle Fenstermasse sind mitverkleinert.
\newlength{\dsakapitelrahmenb} \setlength{\dsakapitelrahmenb}{91.02mm}
\newlength{\dsakapitelrahmenh} \setlength{\dsakapitelrahmenh}{249.97mm}
% Das Fenster endet am hoechsten Punkt jeder Kante, nicht am tiefsten: die
% Kanten sind gezeichnet und schwanken. Gemessen ueber den Fensterbereich
% liegt die untere zwischen 259,76 und 267,80 mm -- 8,04 mm Streuung --, die
% innere linke zwischen 6,10 und 7,03, die rechte zwischen 92,88 und 93,47,
% die obere zwischen 0,00 und 0,17 mm.
%
% Mit dem tiefsten Punkt als Mass schaute das Bild acht Millimeter unter der
% Zierkante hervor. Also der hoechste Punkt plus drei Zehntel Sicherheit:
% x 7,33 bis 92,58 mm und y 0,47 bis 259,46 mm, verkleinert mit 0,8333.
\newlength{\dsakapitelfensterx} \setlength{\dsakapitelfensterx}{6.11mm}
\newlength{\dsakapitelfenstery} \setlength{\dsakapitelfenstery}{0.39mm}
\newlength{\dsakapitelfensterb} \setlength{\dsakapitelfensterb}{71.04mm}
\newlength{\dsakapitelfensterh} \setlength{\dsakapitelfensterh}{215.82mm}

% Die Lage der Datei: auf rechten Seiten beginnt ihre Deckung an der zweiten
% Spalte, auf linken endet sie an der inneren Kante der ersten.
\newlength{\dsakapitelrahmenlinks}
\setlength{\dsakapitelrahmenlinks}{105.07mm}
\newlength{\dsakapitelrahmenrechts}
\setlength{\dsakapitelrahmenrechts}{95.41mm}
\newlength{\dsakapitelrahmenoben}
\setlength{\dsakapitelrahmenoben}{24mm}

% Ist das Kapitelbild schon in die Form der Rahmenoeffnung gebracht? Dann
% wird es in Rahmengroesse gelegt statt in das Rechteck im Fenster.
% \dsaKapitelbildform gilt fuer das naechste Kapitel und schaltet sich
% danach ab.
\newif\ifdsa@kbform
\newcommand*{\dsaKapitelbildform}{\dsa@kbformtrue}

\newcommand{\dsa@rahmenknoten}[1]{%
    \ifodd\value{page}
      \def\dsa@kbanker{north west}%
      \def\dsa@kbversatz{\dsakapitelrahmenlinks}%
    \else
      \def\dsa@kbanker{north east}%
      \def\dsa@kbversatz{-\dsakapitelrahmenrechts}%
    \fi
    % Der Rahmenknoten, an der Papierecke aufgehaengt und in den
    % Satzspiegel gesetzt. Als Phantom, damit die Ecke fuer das Bild da ist.
    \node[anchor=\dsa@kbanker, inner sep=0] (dsakb)
      at ([shift={(\dsa@kbversatz,-\dsakapitelrahmenoben)}]%
          current page.north \ifodd\value{page}west\else east\fi)
      {\phantom{\includegraphics[width=\dsakapitelrahmenb,%
         height=\dsakapitelrahmenh]{\dsagrafik{kapitelstart-rahmen}}}};
    % Erst das Bild, dann der Rahmen darueber.
    %
    % Ohne Bild kommt der Platzhalter: eine Pergamenttextur in der FORM der
    % Rahmenoeffnung. Die ist kein Rechteck -- die untere Kante ist gerissen
    % und schwankt ueber 8 mm, das Ornament sitzt mitten in der Flaeche.
    % aufbereiten.py legt sie als kapitelstart-flaeche an, so gross wie der
    % Rahmen; sie wird deckungsgleich darauf gelegt.
    %
    % Mit Bild gibt es zwei Wege. Ein Rohbild kommt in das Rechteck im
    % Fenster: sicher, aber ohne die gerissene Kante. Ein Bild, das mit
    % werkzeuge/freistellen.py in die Form gebracht ist, gehoert in
    % Rahmengroesse -- dafuer steht \dsaKapitelbildform davor.
    \if\relax\detokenize{#1}\relax
      \node[anchor=\dsa@kbanker, inner sep=0]
        at ([shift={(\dsa@kbversatz,-\dsakapitelrahmenoben)}]%
            current page.north \ifodd\value{page}west\else east\fi)
        {\includegraphics[width=\dsakapitelrahmenb,%
          height=\dsakapitelrahmenh]{\dsagrafik{kapitelstart-flaeche}}};
    \else
      \ifdsa@kbform
        \node[anchor=\dsa@kbanker, inner sep=0]
          at ([shift={(\dsa@kbversatz,-\dsakapitelrahmenoben)}]%
              current page.north \ifodd\value{page}west\else east\fi)
          {\includegraphics[width=\dsakapitelrahmenb,%
            height=\dsakapitelrahmenh]{#1}};
      \else
        \node[anchor=north west, inner sep=0]
          at ([shift={(\dsakapitelfensterx,-\dsakapitelfenstery)}]dsakb.north west)
          {\dsaBildDeckend{\dsakapitelfensterb}{\dsakapitelfensterh}{#1}};
      \fi
    \fi
    \node[anchor=\dsa@kbanker, inner sep=0]
      at ([shift={(\dsa@kbversatz,-\dsakapitelrahmenoben)}]%
          current page.north \ifodd\value{page}west\else east\fi)
      {\includegraphics[width=\dsakapitelrahmenb,%
        height=\dsakapitelrahmenh]{\dsagrafik{kapitelstart-rahmen}}};%
    \global\dsa@kbformfalse}

% Der Rahmen in eigenem Bild -- fuer den alten Namen und fuer den Fall,
% dass ihn jemand einzeln setzen will.
\newcommand{\dsa@kapitelrahmen}[1]{%
  \begin{tikzpicture}[remember picture, overlay]
    \dsa@rahmenknoten{#1}%
  \end{tikzpicture}}

% Der alte Name, damit bestehende Dokumente weiterlaufen.
\newcommand{\dsaKapitelbild}[1]{\dsa@kapitelrahmen{#1}}
% Pergament und Ornament sind native 109,2 x 300,0 mm — beide Masse zu
% erzwingen ist hier exakt, nicht Streckung.
% Steht ein Kapitelbild, muss die Anfangsseite mit \dsaKapitelseiteEnde
% beendet werden, sonst laeuft der Text dahinter.
\newcommand*{\dsaKapitelseiteEnde}{\clearpage}

% Unterkapitel: Andalus 18,9 pt, zentriert, 12 pt danach. Das Absatzformat
% „Absatzueberschrift" der IDML nennt PointSize 14 und dazu Horizontal- und
% VerticalScale von je 135 — 14 mal 1,35 sind 18,9, und genau 18,90 pt liest
% man an den sieben Zwischenueberschriften des Musterbogens.
\newcommand*{\dsaunterkapitelgrad}{18.9}
\newcommand{\dsaunterkapitel}[1]{%
  \par\dsaRasterluft{1}%
  % Ohne eigenen Anker zeigen alle Unterkapitel eines Kapitels auf den
  % Anker des Kapitels, und hyperref meldet "The anchor of a bookmark and
  % its parent's must not be the same".
  \phantomsection
  \addcontentsline{toc}{subsection}{#1}%
  % Zwei Rastereinheiten: eine fuer die Zeile, eine fuer den Abstand danach,
  % den die IDML als SpaceAfter 12 pt nennt. \dsa@lineskipraster haelt den
  % Durchschuss, obwohl die Zeile hoeher ist als er.
  {\centering\dsa@lineskipraster
   \dsaandalus\fontsize{\dsaunterkapitelgrad bp}{24bp}\selectfont #1\par}%
  \dsaRasterluft{1}\nobreak}

\newcommand{\dsaabschnitt}[1]{%
  \par\dsaRasterluft{1}%
  % Eine Rastereinheit. Der Baukasten gibt dieser Ueberschrift keinen
% eigenen Abstand.
  {\dsa@lineskipraster\bfseries\fontsize{13bp}{12bp}\selectfont #1\par}%
  \nobreak}

\newcommand{\dsaunterabschnitt}[1]{%
  \par{\bfseries #1\par}\nobreak}

% Abschnitt mit Pergamentverlauf, Farbfeld „Fuer Gelb" des Baukastens.
% Der Abschnitt auf Pergamentverlauf. Der Baukasten gibt fuer dieses
% Element keine Masse her, also nach der Regel des Rasters: die Flaeche ist
% \dsaabschnittgelbeinheiten Einheiten hoch, ihr Text sitzt mittig darin auf
% einer Grundlinie, davor und danach eine Leerzeile.
%
% Wie beim Tabellenkopf darf die Box nicht als eigener Absatz stehen: mit
% 1 mm oben, 1 mm unten und einer 13-bp-Zeile war sie knapp 19 bp hoch, also
% hoeher als der Durchschuss und keine ganze Zahl von Einheiten. Gemessen lag
% die Ueberschrift 4,1 bp neben dem Raster und der Text danach 1,9 bp.
%
% \dsaabschnittgelbtiefer schiebt die Flaeche so weit nach unten, dass ihr
% Text auf der Grundlinie seiner Zeile sitzt.
\newcommand*{\dsaabschnittgelbeinheiten}{2}
\newlength{\dsaabschnittgelbtiefer}
\setlength{\dsaabschnittgelbtiefer}{8.6bp}

\newcommand{\dsaAbschnittGelb}[1]{%
  \par\dsaRasterluft{1}%
  \nobreak\noindent
  \makebox[\linewidth][l]{%
    \raisebox{-\dsaabschnittgelbtiefer}[0pt][0pt]{%
      \begin{tcolorbox}[
        enhanced, blankest, nobeforeafter, width=\linewidth,
        height=\dsaRaster{\dsaabschnittgelbeinheiten}, valign=center,
        left=2mm, right=2mm, top=0pt, bottom=0pt,
        interior style={left color=dsapergamentgelb, right color=white}]
        \dsa@lineskipraster\bfseries\fontsize{13bp}{12bp}\selectfont #1
      \end{tcolorbox}}}%
  \par
  \dsaRasterluft{1}\nobreak}

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
% OFFEN: beide geschaetzt und fuer alle Kaesten gueltig. Der Musterbogen
% zeigt auf Seite 7 nur die gezeichneten Kaesten mit Text — dort sind es
% 3,0 mm links und 2,25 mm rechts, aber diese Kaesten haben keinen
% Zierrand. Die Grafikkaesten zeigt er ohne Text, und damit gibt er den
% Innenabstand nicht her. Wer einen gesetzten Band mit Pergamentkasten hat,
% misst nach.

% Der Text im Kasten ist kleiner als der Fliesstext: 9,5 pt auf 11,4 pt. So
% nennen es die Absatzformate der IDML („4_Pergamentkasten",
% „Kasten_optional_Text"), und so steht es im Musterbogen -- dort liegen die
% Grundlinien im Kasten 4,02 mm auseinander, das 1,2fache von 9,5 pt.
%
% Der Kastentext folgt dabei NICHT dem Grundlinienraster der Seite: im
% Musterbogen weichen seine Zeilen um 0,4 bis 2,8 pt davon ab, wachsend von
% Zeile zu Zeile. Ein Kasten ist ein eigener Satzraum, und das ist auch
% sinnvoll -- sonst passte in einen Kasten von zwoelf Rastereinheiten kaum
% Text.
\newcommand*{\dsakastengrad}{9.5}
\newcommand*{\dsakastendurchschuss}{11.4}

% Die Voreinstellung gilt fuer die Pergamentkaesten, deren Zierrand nur
% 2,9 bis 4,2 mm breit ist. Die Wertekaesten haben breitere Raender und
% setzen top und bottom selbst -- gemessen mit werkzeuge/innenraum.py.
\tcbset{dsa@grundkasten/.style={
  enhanced, breakable=false, blankest, nobeforeafter, valign=top,
  left=\dsakasteninnen, right=\dsakasteninnen,
  top=\dsakastenoben,   bottom=\dsakastenoben,
  fontupper=\fontsize{\dsakastengrad bp}{\dsakastendurchschuss bp}\selectfont}}

% Der Ueberhang verschiebt den Kasten, er macht ihn nicht breiter.
%
% „grow to left by" waere das Naheliegende, macht die Box aber breiter als
% die Kastengrafik — und der Text folgt der Box. Gemessen sass er dann links
% 7,9 mm vom Grafikrand und rechts 2,7 mm. „enlarge left by" mit negativem
% Wert verschiebt die Box nach links und laesst ihre Breite, weil die mit
% „width" gesetzt ist.
\tcbset{dsaueberhang/.style={enlarge left by=-#1}}

% ACHTUNG, planmaessige Meldung. Der Kasten ist breiter als die Spalte und
% wird nur nach links verschoben, nicht verschmaelert. Rechts steht er
% deshalb ueber, und TeX meldet fuer den Absatz, der ihn traegt, genau
% diesen Ueberhang:
%
%   dsaPergament*    2,5 mm   ->  7,11 pt Overfull \hbox
%   dsaWerteKlein    1,95 mm  ->  5,55 pt
%   dsaWerteGross    2,25 mm  ->  6,40 pt
%   dsaWerteMittel   3,2 mm   ->  9,10 pt
%
% Das ist kein Fehler, sondern der Zierrand, der ausserhalb des
% Textbereichs liegen soll. Wer im Log nach echten Overfulls sucht, zieht
% diese Werte ab.

% Die Lage der Portraitkaesten: sie sind 13,5 mm breiter als eine Spalte, und
% der Musterbogen verteilt das ungleich — 5,1 mm nach innen, 8,4 mm nach
% aussen, wo auch das Medaillon sitzt. Gemessen auf beiden Seitenlagen des
% Musterbogens, an allen drei Groessen.
%
% Der Kasten steht vorlaeufig nur auf rechten Seiten, weil der Baukasten die
% Grafik nur in einer Lage liefert; dort ist innen links und aussen rechts.
% Der rechte Innenabstand im Portraitkasten: so weit muss der Text vom Rand
% wegbleiben, damit er nicht unter das Medaillon laeuft.
%
% Das Mass ist der KRANZ des Ornaments, nicht das Bild darin. Die Ringmitte
% sitzt 17,6 mm vom rechten Rand der Kastengrafik, der deckende Kranz hat
% einen Radius von 15,5 mm und reicht damit 33,2 mm nach innen. Bei 30 mm
% Abstand lief der Text 3,2 mm darunter, bei 24 mm sogar 5,7 mm.
%
% Damit bleiben 94 - 7 - 34 = 53 mm Textbreite. Das ist schmal und mehr, als
% noetig waere, denn das Medaillon sitzt nur im oberen Drittel. Die Breite
% darunter gibt \dsaPortraitfluss zurueck, gleich hier darunter.
\newlength{\dsaportraitfrei}\setlength{\dsaportraitfrei}{34mm}

% \dsaPortraitfluss am Anfang des Kasteninhalts: der Text umfliesst das
% Medaillon. Gilt fuer den Absatz, der folgt — bei mehreren Absaetzen also
% den ersten. Wer den Fluss ueber einen ganzen Kasten braucht, setzt den
% Text als einen Absatz.
%
% Der Kranz ist ein Kreis, also ist der Einzug je Zeile ein anderer. Ein
% rechteckiger Einzug -- wie hier zuvor -- laesst links Platz liegen und
% stoesst rechts trotzdem an.
%
% Gerechnet mit dem Kranz des kleinen Kastens, weil er am tiefsten und am
% weitesten innen sitzt; damit reicht eine Liste fuer alle drei. Mitte
% 76,94 mm von der linken Kastenkante und 17,97 mm unter der Oberkante,
% Radius 15,62 mm plus 2,5 mm Luft -- mit 0,8 mm stand der Text zu dicht am
% Kranz. Der Textbereich beginnt 7 mm von der
% Kante und endet 81,82 mm davon -- das ist die Innenkante des Zierrands
% rechts (11,18 mm) plus ein Millimeter Luft.
%
% Je Zeile ist der weiteste Vorstoss des Kreises innerhalb der Zeilenhoehe
% maßgeblich, nicht der auf der Grundlinie: bei 9,5 bp reicht die Zeile
% 2,35 mm ueber die Grundlinie und 1,01 mm darunter.
%
% \parshape verlangt seine Zeilen ausgeschrieben, eine Wiederholung kennt es
% nicht. Wer die Masse aendert, rechnet die Liste neu -- und aendert die 8
% davor.
\newcommand*{\dsaPortraitfluss}{%
  \parshape 8
    0pt 52.76mm
    0pt 51.90mm
    0pt 51.82mm
    0pt 52.07mm
    0pt 53.23mm
    0pt 55.57mm
    0pt 59.86mm
    0pt 74.82mm}

\newlength{\dsaportraitinnen}\setlength{\dsaportraitinnen}{5.1mm}
\newlength{\dsaportraitaussen}\setlength{\dsaportraitaussen}{8.4mm}
\tcbset{dsaportraitlage/.style={
  enlarge left by=-\dsaportraitinnen}}

% \dsaKastenNeu{<Umgebung>}{<Breite>}{<Grafikhoehe>}{<Rastereinheiten>}
%              {<Grafik>}{<weitere Schluessel>}
\newlength{\dsa@kastenbreite}
\newsavebox{\dsa@kastenbox}

% Der Kasten steht in einer Box OHNE Hoehe und Tiefe, und seinen Raum
% liefert \dsaRasterluft -- dieselbe Bauform wie \dsaProbe.
%
% Vorher stand er als gewoehnliche Box in der vertikalen Liste. Seine Hoehe
% ist zwar ein Vielfaches von 12 bp, aber sie ist groesser als
% \baselineskip, und dann legt TeX keinen Durchschuss mehr davor, sondern
% faellt auf \lineskip zurueck. Der Kasten sass damit richtig, alles unter
% ihm nicht mehr: gemessen an einem Abzug mit Text vor und nach dem Kasten
% lagen die Zeilen danach 3,44 bp neben dem Raster (dsaPergamentMittel) und
% 3,97 bp (dsaWerteMittel).
%
% Aufgefallen ist es lange nicht, weil beispiel/kaesten.tex jeden Kasten
% allein auf eine Seite setzt und mit \clearpage abschliesst — dort steht
% hinter keinem Kasten eine Zeile, die daneben liegen koennte. Erst ein
% Kasten mitten im Fliesstext bringt es ans Licht, und im Solo ist das der
% Regelfall.
%
% Die Box wird erst gesetzt und dann gehoben: \raisebox nimmt ein Argument,
% keine Umgebung, und tcolorbox laeuft ueber \begin und \end. Deshalb der
% Umweg ueber die savebox.
%
% \dsa@kastenauf und \dsa@kastenzu{<Einheiten>} klammern jeden Kasten der
% Klasse ein -- die fertigen aus \dsaKastenNeu ebenso wie die beiden in
% freier Hoehe, die ihre tcolorbox selbst bauen. Die Regel gilt fuer alle
% oder fuer keinen: ein Kasten, der sie nicht befolgt, verschiebt den Satz
% unter sich genauso wie vorher.
% Die Einheitenzahl wird beim Oeffnen gemerkt, weil der Schlussteil einer
% \newenvironment die Argumente der Umgebung nicht mehr sieht.
\newcommand*{\dsa@kasteneinheiten}{0}

\newcommand{\dsa@kastenauf}[1]{%
  \gdef\dsa@kasteneinheiten{#1}%
  \par\nobreak
  \begin{lrbox}{\dsa@kastenbox}}

\newcommand{\dsa@kastenzu}{%
  \end{lrbox}%
  \noindent\makebox[\linewidth][l]{%
    \raisebox{-\dsaRaster{\dsa@kasteneinheiten}}[0pt][0pt]{%
      \usebox{\dsa@kastenbox}}}%
  \par\dsaRasterluft{\dsa@kasteneinheiten}\nobreak}

\newcommand{\dsaKastenNeu}[6]{%
  \newtcolorbox{dsa@kasten@#1}[1][]{%
    dsa@grundkasten,
    % Die Breite der Kastengrafik merken: das Portraitmedaillon braucht sie,
    % weil es an der Grafik haengt und nicht am Rahmen.
    /utils/exec={\setlength{\dsa@kastenbreite}{#2}},
    width=#2, height=\dsaRaster{#4},
    underlay={\node[anchor=north west, inner sep=0] at (frame.north west)
      {\includegraphics[width=#2,height=#3]{\dsagrafik{#5}}};},
    #6, ##1}%
  \newenvironment{#1}[1][]{%
    \dsa@kastenauf{#4}%
    \begin{dsa@kasten@#1}[##1]%
  }{%
    \end{dsa@kasten@#1}%
    \dsa@kastenzu}}

% ---- Pergament ----
\dsaKastenNeu{dsaPergamentKlein} {85.5mm} {50.7mm} {12}{pergament-klein} {dsaueberhang=2.5mm}
\dsaKastenNeu{dsaPergamentMittel}{85.5mm} {99.5mm} {24}{pergament-mittel}{dsaueberhang=2.5mm}
\dsaKastenNeu{dsaPergamentLang}  {85.5mm} {192.4mm}{46}{pergament-lang}  {dsaueberhang=2.5mm}
% Breit und schmal passen nicht in eine Spalte — einspaltig setzen.
% Der Baukasten rahmt diese Grafik mit 136,57 x 189,26 mm, die
% Produktionsgroesse ist 136,90 x 192,37. Geklaert: der Rahmen traegt
% ActualPpi 300 und EffectivePpi 301 — die beiden sind ungleich, das Bild
% liegt also nicht auf 100 Prozent, und der Rahmen ist kein Sollmass. Der
% Unterschied ist ein Beschnitt von 3,1 mm in der Hoehe. Es gilt die
% Produktionsgroesse.
\dsaKastenNeu{dsaPergamentBreit} {136.9mm}{192.4mm}{46}{pergament-breit} {}
% Produktionsgroesse, hochkant. Der Musterbogen des Baukastens zeigt diese
% Grafik GEDREHT, 186,08 x 47,26 mm — eine Vorfuehrung, keine Vorschrift.
\dsaKastenNeu{dsaPergamentSchmal}{48.9mm} {192.4mm}{46}{pergament-schmal}{left=6mm,right=6mm}

% ---- Wertekaesten ----
\dsaKastenNeu{dsaWerteKlein} {84.4mm}{54.8mm} {13}{werte-klein} {dsaueberhang=1.95mm,left=7mm,right=7mm,top=6.7mm,bottom=6.1mm}
\dsaKastenNeu{dsaWerteMittel}{86.9mm}{103.8mm}{25}{werte-mittel}{dsaueberhang=3.2mm,left=7mm,right=7mm,top=7.8mm,bottom=5.2mm}
\dsaKastenNeu{dsaWerteGross} {85.0mm}{197.1mm}{47}{werte-gross} {dsaueberhang=2.25mm,left=7mm,right=7mm,top=6.8mm,bottom=4.1mm}

% ---- Wertekaesten mit Portrait ----
%
% Alle drei sind 94,0 mm breit; das Medaillon tritt 13,5 mm zur Aussenseite
% heraus. Vorlaeufig nur die rechte Lage — der Baukasten liefert die Grafik
% nur in einer Richtung.
%
% Das Portraitbild kommt als Schluessel, damit es im underlay landet: den
% TikZ-Knoten „frame" gibt es nur dort, nicht im Kasteninhalt.

% Nicht die Groesse des Ornaments (35,4 mm), sondern die seines freien
% Innenkreises: 21,0 mm, gemessen im Alphakanal von portraitrahmen.png. Zwei
% Millimeter mehr, damit das Bild unter den Kranz reicht und keine Fuge bleibt.
% Der Durchmesser des Bildes im Medaillon. Der freie Innenkreis ist 21,0 mm;
% weil der Kranz darueber liegt und die Kante verdeckt, darf das Bild
% groesser sein. 26 mm lassen unter keinen Umstaenden eine Fuge.
\newlength{\dsaportraitgroesse} \setlength{\dsaportraitgroesse}{26mm}
% Die Groesse des Ornaments und der Versatz seines Kranzes gegen die
% Bildmitte: der Kranz reicht von Pixel 16 bis 383 von 418, seine Mitte liegt
% also 0,81 mm links der Mitte der Datei.
\newlength{\dsaportraitring}    \setlength{\dsaportraitring}{35.4mm}
\newlength{\dsaportraitringx}   \setlength{\dsaportraitringx}{0.81mm}
% Die Lage der Kranzmitte. Nicht geschaetzt: die drei Kastengrafiken
% enthalten das Medaillon bereits, also ist die Lage im Alphakanal zu messen,
% und unser Ring muss deckungsgleich darauf liegen.
%
% Gemessen an den drei Dateien bei 300 ppi, jeweils aus zwei Wegen -- dem
% Scheitel oben plus Kranzradius und dem rechtesten Punkt:
%
%   werte-klein-portrait    17,06 mm von rechts, 17,97 mm unter der Oberkante
%   werte-mittel-portrait   17,91 mm             16,87 mm
%   werte-gross-portrait    17,57 mm             16,62 mm
%
% Der sichtbare Kranzradius ist in allen drei Dateien 15,62 mm, genau wie in
% portraitrahmen.png. Die frueheren 19,4 mm kamen daher, dass dort der
% Aussenradius der Ringdatei gerechnet wurde -- 17,7 mm, die halbe
% Bildbreite -- und nicht der Kranz.
%
% Die Werte streuen um 1,4 mm, weil die Dateien unterschiedlich beschnitten
% sind. Jeder Kasten setzt deshalb seine eigenen; die Voreinstellung ist der
% Mittelwert und gilt, wenn jemand den Stil ohne Kasten benutzt.
\newlength{\dsaportraitx}       \setlength{\dsaportraitx}{17.51mm}
\newlength{\dsaportraity}       \setlength{\dsaportraity}{17.15mm}

% Je Kasten die gemessene Lage. \dsaKastenNeu gibt die Liste an tcolorbox
% weiter; „code" wird beim Setzen der Optionen ausgefuehrt, also vor dem
% Overlay, das die Laengen liest.
\tcbset{dsaportraitlagen/.style 2 args={code={%
  \setlength{\dsaportraitx}{#1}\setlength{\dsaportraity}{#2}}}}
% Die Groesse steht im IDML: Ornament_Portrait_Wertekasten.psd sitzt in einem
% Rahmen von 35,39 x 34,97 mm bei 300 gegen 300 ppi, also in 100 Prozent. Das
% ist die Aussenkante des Rings; das Bild darin ist kleiner, weil der Ring
% selbst Breite hat.
% Wo im Kasten es sitzt, sagt das IDML nicht -- das steht in den
% Kastengrafiken selbst, siehe oben.

% „overlay app" haengt an, was schon an Overlays da ist, und zeichnet ueber
% den Inhalt. Genau richtig fuer das Medaillon, das ueber den Rand des
% Kastens hinaustritt. Ein „underlay app" gibt es in tcolorbox nicht.
%
% Der Anker ist die GRAFIK, nicht der Rahmen: „frame" ist durch den Ueberhang
% breiter als die Kastengrafik, und am Rahmen aufgehaengt ragte das Medaillon
% um genau diesen Betrag hinaus. Die Grafik sitzt an frame.north west und ist
% \dsa@kastenbreite breit — die merkt der Generator.
% Zwei Lagen: das Bild, darueber der Ring. „overlay app" zeichnet beide ueber
% den Inhalt, in der Reihenfolge, in der sie hier stehen.
\tcbset{dsaportrait/.style={overlay app={%
  \node[inner sep=0]
    at ([shift={(\dsa@kastenbreite-\dsaportraitx,-\dsaportraity)}]%
        frame.north west)
    {\dsaBildKreis{\dsaportraitgroesse}{#1}};
  \node[inner sep=0]
    at ([shift={(\dsa@kastenbreite-\dsaportraitx+\dsaportraitringx,%
                 -\dsaportraity)}]frame.north west)
    {\includegraphics[width=\dsaportraitring]{\dsagrafik{portraitrahmen}}};}}}

\dsaKastenNeu{dsaWerteKleinPortrait} {94.0mm}{59.2mm} {14}{werte-klein-portrait} {dsaportraitlage,dsaportraitlagen={17.06mm}{17.97mm},left=7mm,right=\dsaportraitfrei,top=9.8mm,bottom=10.1mm}
\dsaKastenNeu{dsaWerteMittelPortrait}{94.0mm}{104.0mm}{25}{werte-mittel-portrait}{dsaportraitlage,dsaportraitlagen={17.91mm}{16.87mm},left=7mm,right=\dsaportraitfrei,top=8.9mm,bottom=9.6mm}
\dsaKastenNeu{dsaWerteGrossPortrait} {94.0mm}{199.1mm}{47}{werte-gross-portrait} {dsaportraitlage,dsaportraitlagen={17.57mm}{16.62mm},left=7mm,right=\dsaportraitfrei,top=8.6mm,bottom=4.8mm}

% ---- Graue Kaesten ----
%
% meister-schmal ist HOCHKANT, 59,9 x 114,2 mm. meister-breit ist mit
% 177,9 mm breiter als die Satzbreite von 166 mm und ragt je Seite 5,95 mm
% hinaus — einspaltig setzen.
% Das IDML rahmt Meisterkasten.psd mit 84,60 x 42,25 mm — quer, obwohl die
% Grafik mit 707 x 1349 px hochkant ist. Geklaert: die ItemTransform des
% Rahmens dreht um 180 Grad, und ActualPpi 300 steht gegen EffectivePpi 425.
% Das Bild liegt dort also auf 70,6 Prozent und ist beschnitten; der Rahmen
% ist kein Sollmass. Es gilt die Produktionsgroesse. Derselbe Griff in die
% ItemTransform bestaetigt die Drehung von Kasten_Pergament_sehr schmal:
% minus 90 Grad, bei EffectivePpi 310.
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
  \dsa@kastenauf{#2}%
  \begin{tcolorbox}[
    dsa@grundkasten,
    width=85.5mm, height=\dsaRaster{#2},
    dsaueberhang=2.5mm, top=8mm, bottom=8mm,
    underlay={%
      % Die Pergamentflaeche wird beschnitten, nicht gestaucht: bei 14
      % Rastereinheiten waeren aus 192,4 mm Grafik 59,3 mm zu machen, ein
      % Faktor von 3,2, und die Textur waere sichtbar gequetscht.
      \node[anchor=north west, inner sep=0] at (frame.north west)
        {\dsaBildDeckend{85.5mm}{\dsaRaster{#2}}{\dsagrafik{pergament-lang}}};
      % 55,80 x 10,37 mm: das Rahmenmass von Absatztrenner_oben.psd im IDML.
      \node[anchor=north, inner sep=0] at (frame.north)
        {\includegraphics[width=55.8mm,height=10.37mm]{\dsagrafik{trenner-oben}}};
      \node[anchor=south, inner sep=0] at (frame.south)
        {\includegraphics[width=55.8mm,height=10.37mm]{\dsagrafik{trenner-unten}}};},%
      % trenner-unten traegt das Auge -- der allgemeine Abschluss. Die
      % Maskenleiste (trenner-maske) gehoert an einen Meisterhinweis, die
      % Buchleiste (trenner-buch) an einen Vorlesetext.
    #1]%
}{\end{tcolorbox}\dsa@kastenzu}
% Die Pergamentflaeche wird beschnitten statt gestreckt, und
% pergament-lang hat auch in der Flaeche eine gezeichnete Kante. Sauberer
% waere ein Mittelstreifen zum Kacheln.

% ---- Wertekasten mit Medaillon in freier Hoehe ----
%
% Der Gegner- und Kreaturkasten. Befund an einem offiziellen, gesetzten Solo
% des Verlags (68 Seiten A4, liegt nicht im Projekt, wird nicht benannt):
% fuenf solche Kaesten, alle gleich gebaut, aber in VIER verschiedenen
% Hoehen -- gemessene Koerperhoehen 72,7 / 73,4 / 76,9 / 78,1 mm. Der Kasten
% waechst also mit seinem Inhalt, und die drei festen Hoehen des Baukastens
% (59,2 / 104,0 / 199,1 mm) treffen keine davon.
%
% Die Maessse des Hefts sind dabei NICHT die Sollmaesse -- es hat einen
% eigenen Satzspiegel, 92,6 mm Koerperbreite gegen 94,0 mm der Vorlage. Es
% belegt nur, DASS es den Kasten in freier Hoehe gibt. Gebaut wird er
% deshalb aus der Vorlagengrafik.
%
% Drei Scheiben aus werte-gross-portrait, alle in wahrer Groesse:
%
%   Kopf   0,00 .. 35,60 mm   Zierleiste und Medaillonring
%   Mitte  35,60 .. je nach Hoehe   Pergament mit den dunklen Seitenkanten
%   Fuss   186,25 .. 199,05 mm  Zierleiste mit dem Ornament
%
% Kein \dsaBildDeckend wie bei dsaKastenFrei: das beschneidet mittig und
% wuerde hier beide Zierleisten und den Ring zerschneiden. Gemessen an der
% Grafik (2351 px / 300 ppi = 199,05 mm): die Kopfleiste liegt dunkel von
% 4,49 bis 8,13 mm, die Fussleiste von 189,99 bis 196,34 mm, und der Ring
% reicht nach doku/MASSE.md bis 32,1 mm unter die Oberkante -- 16,62 mm
% Mitte plus 15,5 mm halber Aussendurchmesser. Die Kopfscheibe von 35,60 mm
% traegt beide vollstaendig.
%
% Weil nur beschnitten und nie gestreckt wird, ist die Textur an den zwei
% Naehten dieselbe wie im Rest der Flaeche.
\newlength{\dsawertefreihoehe}  \setlength{\dsawertefreihoehe}{199.05mm}
\newlength{\dsawertefreikopf}   \setlength{\dsawertefreikopf}{35.60mm}
\newlength{\dsawertefreifuss}   \setlength{\dsawertefreifuss}{12.80mm}
% Hilfslaengen fuer die drei Beschnitte.
\newlength{\dsa@wfmitte}\newlength{\dsa@wfa}\newlength{\dsa@wfb}\newlength{\dsa@wfc}

% \begin{dsaWerteFreiPortrait}[<Schluessel>]{<Rastereinheiten>}
%
% Kopf und Fuss brauchen zusammen 48,40 mm, also 11,43 Rastereinheiten --
% unter 12 gibt es keine Flaeche mehr fuer die Mitte. Nach oben ist bei 47
% Schluss, dort ist die Grafik zu Ende; das ist genau dsaWerteGrossPortrait.
\newtcolorbox{dsa@kasten@wfp}[2][]{%
  dsa@grundkasten,
  /utils/exec={%
    \setlength{\dsa@kastenbreite}{94.0mm}%
    \ifnum#2<12
      \ClassWarning{dsa5latex}{dsaWerteFreiPortrait mit #2 Rastereinheiten ist
        zu niedrig -- Kopf und Fuss brauchen zusammen 12. Der Kasten wird
        falsch gesetzt}%
    \fi
    \ifnum#2>47
      \ClassWarning{dsa5latex}{dsaWerteFreiPortrait mit #2 Rastereinheiten ist
        hoeher als die Vorlagengrafik (47). Die Mitte wird gestreckt}%
    \fi
    \setlength{\dsa@wfmitte}{\dimexpr\dsaRaster{#2}-\dsawertefreikopf-\dsawertefreifuss\relax}%
    % Beschnitt unten fuer die Kopfscheibe, oben fuer die Fussscheibe,
    % und fuer die Mitte beides.
    \setlength{\dsa@wfa}{\dimexpr\dsawertefreihoehe-\dsawertefreikopf\relax}%
    \setlength{\dsa@wfb}{\dimexpr\dsawertefreihoehe-\dsawertefreifuss\relax}%
    \setlength{\dsa@wfc}{\dimexpr\dsawertefreihoehe-\dsawertefreikopf-\dsa@wfmitte\relax}},
  width=94.0mm, height=\dsaRaster{#2},
  underlay={%
    \node[anchor=north west, inner sep=0] at (frame.north west)
      {\includegraphics[width=94.0mm, clip,
        trim={0pt} {\the\dsa@wfa} {0pt} {0pt}]{\dsagrafik{werte-gross-portrait}}};
    \node[anchor=north west, inner sep=0]
      at ([yshift=-\dsawertefreikopf]frame.north west)
      {\includegraphics[width=94.0mm, height=\the\dsa@wfmitte, clip,
        trim={0pt} {\the\dsa@wfc} {0pt} {\the\dsawertefreikopf}]{\dsagrafik{werte-gross-portrait}}};
    \node[anchor=south west, inner sep=0] at (frame.south west)
      {\includegraphics[width=94.0mm, clip,
        trim={0pt} {0pt} {0pt} {\the\dsa@wfb}]{\dsagrafik{werte-gross-portrait}}};},
  % Die Innenmasse von dsaWerteMittelPortrait. Zulaessig, weil die Leisten
  % in allen drei Fassungen gleich weit von der Kante sitzen: die Kopfleiste
  % endet 8,13 bis 9,57 mm unter der Oberkante, die Fussleiste beginnt 9,06
  % bis 9,40 mm ueber der Unterkante. Gemessen an allen drei Grafiken.
  dsaportraitlage, dsaportraitlagen={17.57mm}{16.62mm},
  left=7mm, right=\dsaportraitfrei, top=8.9mm, bottom=9.6mm,
  #1}

% Wie jeder Kasten der Klasse in eine Box ohne Hoehe, damit der Satz unter
% ihm auf dem Raster bleibt -- siehe \dsa@kastenauf.
\newenvironment{dsaWerteFreiPortrait}[2][]{%
  \dsa@kastenauf{#2}%
  \begin{dsa@kasten@wfp}[#1]{#2}%
}{%
  \end{dsa@kasten@wfp}%
  \dsa@kastenzu}

%%% ==================================================================
%%% 14  Vorlesetext, Meistermaske, NSC-Kopf
%%% ==================================================================

% Die Zierleiste ist 158,5 x 29,5 mm gross, wird im Baukasten aber auf
% 95,89 x 17,83 mm platziert — 496 gegen 300 ppi, also auf 60 Prozent
% verkleinert. 95,89 mm sind breiter als eine Spalte (80,5 mm): die Leiste
% laeuft ueber den Satz hinaus, und am Abzug ist entschieden, dass sie das
% auch soll.
% \dsaVorlesetext[<Rastereinheiten>]{<Text>}
%
% Die Zierleiste darueber wird auf Spaltenbreite gesetzt, und ihre Hoehe folgt
% der Proportion der Grafik: 29,5 zu 158,5 ergibt in einer Spalte von 80,5 mm
% rund 42,5 bp. Das ist kein Vielfaches der Rastereinheit, und alles darunter
% sass 4,7 bp neben dem Raster. Die Leiste steht deshalb in einer Box aus
% ganzen Rastereinheiten und darin mittig.
%
% Fuenf Einheiten passen fuer eine Spalte. Einspaltig braucht die Leiste mehr,
% weil sie breiter und damit hoeher wird — dort neun.
% Die Leiste ist breiter als die Spalte und steht mittig darueber -- wie der
% Zierrand der Kaesten, der ebenfalls ausserhalb des Textbereichs liegt.
% Der Baukasten platziert sie auf 95,89 x 17,83 mm bei einer Spalte von
% 80,5 mm, also 15,39 mm breiter. An einer gesetzten Veroeffentlichung
% bestaetigt: dort 89,9 x 16,7 mm bei einer Spalte von 73,4 mm, mittig.
\newlength{\dsavorleseueberhang}
\setlength{\dsavorleseueberhang}{15.39mm}

% Eine Leiste, gesetzt wie ein Bild auf dem Raster: keine eigene Hoehe,
% um #1 Rastereinheiten nach unten geschoben, den Raum gibt \dsaRasterluft.
%
% Fuenf Einheiten fuer eine Spalte: 95,89 mm Breite ergeben 17,83 mm Hoehe,
% also 50,5 bp, und das sprengt vier Einheiten. Einspaltig braucht die
% Leiste neun.
\newcommand{\dsa@vorleseleiste}[2]{%
  \noindent\makebox[\linewidth][c]{%
    \raisebox{-\dsaRaster{#1}}[0pt][0pt]{%
      \includegraphics[width=\dimexpr\linewidth+\dsavorleseueberhang\relax]%
        {\dsagrafik{#2}}}}%
  \par\dsaRasterluft{#1}}

% Zwei Leisten, oben und unten. Oben steht immer dieselbe Leiste
% (trenner-oben); das Motiv der unteren sagt, um welche Art Block es sich
% handelt -- Buch beim Vorlesetext, Maske beim Meisterhinweis, Auge sonst.
%
% Vorher stand die Buchleiste oben und der allgemeine Trenner unten: beides
% untere Leisten, und das Motiv am falschen Ende.
\newcommand{\dsaVorlesetext}[2][5]{%
  \par\dsaRasterluft{1}%
  \dsa@vorleseleiste{#1}{trenner-oben}%
  \nobreak #2\par
  \dsa@vorleseleiste{#1}{trenner-buch}%
  \dsaRasterluft{1}}

% Der Meisterhinweis: derselbe Aufbau, unten die Maskenleiste.
\newcommand{\dsaMeisterhinweis}[2][5]{%
  \par\dsaRasterluft{1}%
  \dsa@vorleseleiste{#1}{trenner-oben}%
  \nobreak #2\par
  \dsa@vorleseleiste{#1}{trenner-maske}%
  \dsaRasterluft{1}}
% OFFEN: Ob der Vorlesetext kursiv gesetzt wird, sagt der Baukasten nicht.
% Nachgesehen: seine IDML kennt kein Absatzformat dafuer, und im Musterbogen
% steht kein solcher Block — die einzigen kursiven Stellen dort sind
% Rubriken und die Ueberschrift „Optionale Regel". Hier aufrecht.

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

% Das IDML rahmt Auge_Schwarz.eps und Auge_Weiss.eps mit 1,69 mm Breite; im
% Musterbogen sitzt das Auge mit 1,66 x 2,95 mm. Gesetzt wird die Breite, die
% Hoehe ergibt sich aus dem Seitenverhaeltnis der Grafik.
\newlength{\dsaaugebreite}\setlength{\dsaaugebreite}{1.69mm}
\newcommand*{\dsaAugeSchwarz}{%
  \smash{\raisebox{0.25\height}{%
    \includegraphics[width=\dsaaugebreite]{\dsagrafik{auge-schwarz}}}}}
\newcommand*{\dsaAugeWeiss}{%
  \smash{\raisebox{0.25\height}{%
    \includegraphics[width=\dsaaugebreite]{\dsagrafik{auge-weiss}}}}}

\newcommand{\dsaFokusregel}[1]{%
  \smash{\raisebox{-0.4\height}{%
    \begin{tikzpicture}
      % 10,57 mm: so gross sitzt die Marke im Musterbogen. Der IDML-Rahmen
      % gibt 9,86 mm, das gesetzte Ergebnis ist groesser.
      \node[inner sep=0] {\includegraphics[width=10.57mm]{\dsagrafik{fokusregel}}};
      \node[inner sep=0] {\footnotesize #1};
    \end{tikzpicture}}}}

\newcommand{\dsaFiole}[1]{%
  \begin{wrapfigure}{#1}{9.06mm}
    \centering\vspace*{-\dsaRaster{1}}%
    \includegraphics[width=9.06mm]{\dsagrafik{fiole}}%
    \vspace*{-\dsaRaster{1}}%
  \end{wrapfigure}}
\newcommand{\dsaSchaedel}[1]{%
  \begin{wrapfigure}{#1}{9.06mm}
    \centering\vspace*{-\dsaRaster{1}}%
    \includegraphics[width=9.06mm]{\dsagrafik{totenkopf}}%
    \vspace*{-\dsaRaster{1}}%
  \end{wrapfigure}}

% Gegnerabstufung. Jede Figur hat im IDML ihr eigenes Rahmenmass, und die
% Hoehen unterscheiden sich: Bauer 3,00 mm, Springer 3,17 mm, Turm 3,27 mm,
% Koenig 3,21 mm. Gesetzt wird deshalb je Figur ihre eigene Hoehe.
\newcommand*{\dsa@figur}[2]{%
  \smash{\raisebox{-0.15\height}{%
    \includegraphics[height=#2]{\dsagrafik{#1}}}}}
\newcommand*{\dsaBauer}{\dsa@figur{icon-bauer}{3.00mm}}
\newcommand*{\dsaSpringer}{\dsa@figur{icon-springer}{3.17mm}}
\newcommand*{\dsaTurm}{\dsa@figur{icon-turm}{3.27mm}}
\newcommand*{\dsaKoenig}{\dsa@figur{icon-koenig}{3.21mm}}

% Die Rautenskala kommt aus der Vorlage, nicht aus TikZ.
%
% Der Baukasten hat sie doch als Grafik: acht fertige Skalen, je 860 x 259
% Pixel und damit 72,81 x 21,93 mm bei 300 ppi. Gemessen liegen ihre vier
% Rauten bei x 1..204, 216..419, 431..634 und 647..850 Pixel; die Teilung
% ist 215. aufbereiten.py schneidet daraus drei Kacheln: eine gefuellte
% rote, eine gefuellte gruene und eine graue, jede eine Raute samt ihrem
% Anteil am Zwischenraum.
%
% Hier werden sie aneinandergesetzt: so viele gefuellte wie verlangt, der
% Rest grau. Die Skala ist damit beliebig lang, und nichts ist
% nachgezeichnet.
%
% \dsaRauten{<gefuellt>}{<gesamt>}{<rot|gruen>}{<Breite>}
% Eigene Register, keine Kratzregister: \dimen@ und \@tempcnta sind in
% einer tabular schon belegt. Damit kamen die Kacheln mit 0,35 statt
% 3,75 mm heraus, und die Tabellenzeilen landeten bei y 346 bis 624 mm.
\newlength{\dsa@rautebreite}
\newcount\dsa@rautezahl
\newcommand{\dsaRauten}[4]{%
  \begingroup
    % Die Breite einer Kachel: die Gesamtbreite durch die Zahl der Rauten.
    \setlength{\dsa@rautebreite}{\dimexpr#4/#2\relax}%
    \dsa@rautezahl=0
    \loop\ifnum\dsa@rautezahl<#1\relax
      \includegraphics[width=\dsa@rautebreite]{\dsagrafik{raute-#3}}%
      \advance\dsa@rautezahl by 1
    \repeat
    \loop\ifnum\dsa@rautezahl<#2\relax
      \includegraphics[width=\dsa@rautebreite]{\dsagrafik{raute-grau}}%
      \advance\dsa@rautezahl by 1
    \repeat
  \endgroup}

% Die beiden gewohnten Aufrufe: vier Rauten, davon #1 gefuellt.
\newcommand{\dsaRautenRot}[2]{\dsaRauten{#1}{4}{rot}{#2}}
\newcommand{\dsaRautenGruen}[2]{\dsaRauten{#1}{4}{gruen}{#2}}

\newcommand*{\dsaBand}[2]{\textsuperscript{#1\,#2}}

%%% ==================================================================
%%% 16  Aufzaehlungen und Absatzformen
%%% ==================================================================

\newlist{dsaliste}{itemize}{4}
\setlist[dsaliste,1]{
  leftmargin=\dimexpr 6mm+\labelsep\relax,
  % partopsep gehoert dazu: enumitem addiert es zu topsep, wenn die
  % Liste nach einem Absatz beginnt. Ohne das sass jede Liste 2 bp zu
  % tief, und alles danach mit ihr.
  topsep=0pt, partopsep=0pt, itemsep=0pt, parsep=0pt,
  % 2,05 mm hoch. Der IDML-Rahmen ist 4,36 x 2,36 mm, im Musterbogen sitzt
  % das Zeichen aber mit 3,78 x 2,05 mm — das gesetzte Ergebnis gilt.
  label={\smash{\raisebox{-0.25\height}{%
    \includegraphics[height=2.05mm]{\dsagrafik{aufzaehlung}}}}}}

\newlist{dsalisteblau}{itemize}{4}
\setlist[dsalisteblau,1]{
  leftmargin=\dimexpr 6mm+\labelsep\relax,
  % partopsep gehoert dazu: enumitem addiert es zu topsep, wenn die
  % Liste nach einem Absatz beginnt. Ohne das sass jede Liste 2 bp zu
  % tief, und alles danach mit ihr.
  topsep=0pt, partopsep=0pt, itemsep=0pt, parsep=0pt,
  label={\smash{\raisebox{-0.25\height}{%
    \includegraphics[height=2.4mm]{\dsagrafik{aufzaehlung-blau}}}}}}

\newlist{dsalisterot}{itemize}{4}
\setlist[dsalisterot,1]{
  leftmargin=\dimexpr 6mm+\labelsep\relax,
  % partopsep gehoert dazu: enumitem addiert es zu topsep, wenn die
  % Liste nach einem Absatz beginnt. Ohne das sass jede Liste 2 bp zu
  % tief, und alles danach mit ihr.
  topsep=0pt, partopsep=0pt, itemsep=0pt, parsep=0pt,
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
% Die Tabelle der Vorlage, am Musterbogen des Baukastens (Seite 8) und an
% seiner IDML nachgemessen:
%
%   Breite             immer die volle Spaltenbreite. Die Linien laufen von
%                      Spaltenkante zu Spaltenkante, die Spalten der Tabelle
%                      verteilen sich darin.
%   Zelleneinzug       1,2 mm = 3,4016 bp auf allen vier Seiten. Zwischen
%                      zwei Spalten also 2,4 mm, am Rand 1,2 mm.
%   senkrechte Linien  keine, auch nicht am Rand.
%   Titelzeile         Verlauf von Tabellenrot nach Papierweiss ueber die
%                      ganze Breite, fett. Linie darueber und darunter,
%                      0,25 pt in 60 Prozent Schwarz.
%   Rubrikzeile        Flaeche in 10 Prozent Schwarz. Das ist im Baukasten
%                      der Spaltenkopf und die Anmerkung am Fuss der
%                      Waffentabellen.
%   jede Zeile         eine Linie darunter, 0,25 pt in 25 Prozent Schwarz.
%
% Die Zellenformate heissen in der IDML „Tabelle Ueber aktuell" (Titel),
% „Anmerkung" (Rubrik) und „Werte"; der Verlauf ist das Farbfeld „Tabelle
% Ueberschrift", von Tabellenrot am Ort 0 nach Papier am Ort 100.
%
% Gemessen an der Waffentabelle auf Musterseite 8: Tabellenkante x 56,69 pt,
% erstes Zeichen x 60,09 pt — genau der Zelleneinzug. Rechte Kante 284,88 pt,
% also 56,69 + 228,19 = die vollen 80,5 mm der Spalte.
%
% Zwei Dinge macht die Klasse anders als die Vorlage, beide mit Grund:
%
% 1. Die Zeilenhoehe. Im Baukasten sind es 15,54 pt, und die liegen auf
%    keiner Rasterlinie: seine Tabellen stehen ausdruecklich nicht im
%    Grundlinienraster, GridAlignment="None" in der IDML. Hier gilt das
%    Raster, eine einzeilige Zeile ist genau eine Rastereinheit.
% 2. Die Grauwerte. In der IDML sind es Tonwerte von CMYK-Schwarz; hier
%    stehen die am gesetzten PDF gemessenen RGB-Werte, siehe Abschnitt 6.

% 1,2 mm. Steht als \tabcolsep in jeder dsaTabelle und als Einzug des
% Titeltextes.
\newlength{\dsatabelleninnen}
\setlength{\dsatabelleninnen}{3.4016bp}

% 0,25 pt fuer jede Linie der Tabelle, aus den Zellenformaten der IDML.
\newlength{\dsatabellenstrich}
\setlength{\dsatabellenstrich}{0.25bp}

% Die Linienfarbe. Bleibt als eigener Befehl erhalten, weil er in Dokumenten
% steht; noetig ist er nicht mehr, dsaTabelle setzt ihn selbst.
\newcommand*{\dsaTabellenlinie}{\arrayrulecolor{dsatabellenlinie}}

% ---- Das Band hinter einer Zeile ----
%
% Titelzeile und Rubrikzeile sind farbige Baender ueber die volle
% Spaltenbreite. Sie duerfen keine eigene Hoehe haben: eine Box, die so hoch
% ist wie der Durchschuss, sprengt die Grundlinienregel, TeX nimmt \lineskip,
% und alles darunter lag gemessen 3,3 bp neben dem Raster. Das Band wird
% deshalb von der Grundlinie aus gezeichnet — \dp\strutbox nach unten, der
% Rest der Rastereinheit nach oben — und belegt genau die Zeile, in der es
% steht.
%
% Frueher stand hier eine tcolorbox mit „blankest, interior style={left
% color=...}". Die zeichnet den Verlauf nicht: „blankest" schaltet das Innere
% ab, und „interior style" holt es nicht zurueck. Am gesetzten PDF gemessen
% war die Leiste ueber die ganze Breite reinweiss. Jetzt zeichnet TikZ.
%
% Das Band liegt auf „Multiplizieren". Der Baukasten schreibt es auf genau der
% Seite vor, auf der seine Tabellen stehen:
%
%   „Tipp: Auch bei Tabellen daran denken, den entsprechenden Rahmen unter
%    Fenster>Effekte auf ‚Multiplizieren' zu stellen."
%
% Das ist keine Feinheit. Ein Verlauf, der deckend nach Weiss blendet, legt
% sein rechtes Ende als weisses Rechteck auf das Pergament — gemessen
% (254,254,254) gegen einen Grund, der im unteren Zehntel der Seite bei
% (243,236,221) liegt. Multipliziert bleibt der Grund stehen.
%
% Nachweisbar ist es am Musterbogen an der grauen Rubrikzeile: 10 Prozent
% Schwarz deckend waere (236,236,236), gemessen sind (232,231,228) — warm,
% also mit dem Pergament darunter. Multipliziert gerechnet: (233,232,229).
%
% \pgfsetblendmode braucht einen Treiber, der Mischmodi kann. XeLaTeX ueber
% xdvipdfmx kann sie: an einer Probe mit vier Baendern ueber einem Verlauf von
% Weiss nach Pergamentgelb liess der multiplizierte Streifen den Grund mit
% (212,171,99) unveraendert stehen, der deckende machte (250,247,246) daraus.
%
% Die Haarlinien unter den Wertezeilen bleiben aussen vor: sie kommen aus
% \noalign und nicht aus TikZ. Bei 0,25 pt in 25 Prozent Schwarz liegt der
% Unterschied auf dem hellen Pergament unter einer Stufe von 255.
%
%   #1  Versatz nach links. Ausserhalb der Tabelle 0pt; in der ersten Zelle
%       einer Tabellenzeile \dsatabelleninnen, weil der Text dort schon um
%       den Zelleneinzug weiter rechts steht.
%   #2  Fuellung als TikZ-Schluessel, etwa „fill=dsatabellengrau" oder
%       „shade, left color=..., right color=...".
%   #3  Farbe der Linien oben und unten. Leer laesst sie weg.
\newlength{\dsa@tabellenbreite}
\newlength{\dsa@bandunten}
\newlength{\dsa@bandoben}
% Die Hoehe des Bandes steht in einem eigenen Makro, damit eine abgeleitete
% Klasse sie umlegen kann, ohne die Zeichnung zu wiederholen — etwa fuer
% einen Satz ohne Grundlinienraster, wo eine Zeile keine Rastereinheit misst
% und eine Kopfzeile mehrzeilig sein darf. Das Band selbst, Rechteck, Verlauf
% und die zwei Linien, bleibt dasselbe.
\newcommand*{\dsa@bandmasse}{%
  \setlength{\dsa@bandunten}{\dp\strutbox}%
  \setlength{\dsa@bandoben}{\dimexpr\dsaRaster{1}-\dp\strutbox\relax}}
\newcommand{\dsa@tabellenband}[3]{%
  \dsa@bandmasse
  \begin{tikzpicture}[overlay, blend mode=multiply]
    \path[#2] (-#1,-\dsa@bandunten)
      rectangle (\dimexpr\dsa@tabellenbreite-#1\relax,\dsa@bandoben);
    \def\dsa@bandlinie{#3}%
    \ifx\dsa@bandlinie\@empty\else
      \path[draw=#3,line width=\dsatabellenstrich]
        (-#1,\dsa@bandoben) -- (\dimexpr\dsa@tabellenbreite-#1\relax,\dsa@bandoben);
      \path[draw=#3,line width=\dsatabellenstrich]
        (-#1,-\dsa@bandunten) -- (\dimexpr\dsa@tabellenbreite-#1\relax,-\dsa@bandunten);
    \fi
  \end{tikzpicture}%
}

% Die Titelzeile. Sie steht vor der Tabelle und ist genau so breit wie sie,
% weil beide die volle Spaltenbreite nehmen.
%
% Der Verlauf laeuft von Tabellenrot nach Papierweiss und liegt auf
% „Multiplizieren" — auf dem Pergament bleibt sein rechtes Ende deshalb
% Pergament und wird nicht weiss. Warum, steht bei \dsa@tabellenband.
\newcommand{\dsaTabellenkopf}[1]{%
  \par
  \noindent
  \setlength{\dsa@tabellenbreite}{\linewidth}%
  \dsa@tabellenband{0pt}%
    {shade,left color=dsatabellenrot,right color=white}%
    {dsatabellenkopflinie}%
  \hspace*{\dsatabelleninnen}\textbf{#1}%
  \par\nobreak}

% Die graue Zeile. Der Baukasten hat zwei davon, beide im Zellenformat
% „Anmerkung": den Spaltenkopf oben und die Anmerkung am Fuss der
% Waffentabellen. Am Musterbogen abgelesen:
%
%   Titelzeile      Gentium Basic Bold 10,0 pt
%   Spaltenkopf     Gentium Basic Bold  9,5 pt
%   Wertezeile      Gentium Basic      10,0 pt, erste Spalte fett
%   Anmerkung       Gentium Basic       9,5 pt, das Wort „Anmerkung" fett
%
% \dsaTabellenrubrik steht ganz am Anfang der Zeile, vor der ersten Zelle,
% und zeichnet das Band:
%
%   \dsaTabellenrubrik \dsaRubrikschrift Name & \dsaRubrikschrift Technik\\
%
% Die 9,5 pt und das Fett muessen leider in jede Zelle. Eine Schriftart
% ueber die Zellengrenze hinweg gibt es in LaTeX nicht: jede Zelle einer
% Tabelle ist eine eigene Gruppe, und ein \bfseries in der ersten waere am
% ersten & wieder vergessen. Der Weg ueber \globaldefs ist begangen und
% wieder verlassen — \fontsize und \selectfont setzen dabei die
% Schriftverwaltung von LaTeX global um, und der Lauf endete mit
% „Missing \endcsname inserted", zehnmal je Tabelle.
%
% \rowcolor taugt fuer das Band nicht: colortbl faerbt die Zellen samt
% \tabcolsep, aber nicht die dehnbare Luft zwischen den Spalten. Gemessen
% blieb in der Mitte einer zweispaltigen Zeile ein weisser Streifen von
% 154 pt.
\newcommand*{\dsatabellenrubrikgrad}{9.5}
\newcommand*{\dsaRubrikschrift}{%
  \fontsize{\dsatabellenrubrikgrad bp}{\dsagrunddurchschuss bp}\selectfont
  \bfseries}
\newcommand*{\dsaAnmerkungsschrift}{%
  \fontsize{\dsatabellenrubrikgrad bp}{\dsagrunddurchschuss bp}\selectfont}
\newcommand*{\dsaTabellenrubrik}{%
  \dsa@tabellenband{\dsatabelleninnen}{fill=dsatabellengrau}{}%
  \ignorespaces}

% Die Linie unter jeder Zeile. \hline taugt nicht: sie bringt ihre
% Strichstaerke als Bauhoehe mit, und die Grundlinien standen gemessen
% 12,25 statt 12,00 bp auseinander — nach vierzig Zeilen ein Zehntel
% Millimeter, nach einer Seite sichtbar. Der \vskip nimmt die Hoehe wieder
% weg, die Linie bleibt.
\newcommand*{\dsa@tabellenlinie}{%
  \noalign{\vskip-\dsatabellenstrich
           {\color{dsatabellenlinie}\hrule \@height\dsatabellenstrich}}}

% Gesetzt wird sie ueber \everycr, damit der Autor sie nicht hinter jede
% Zeile schreiben muss. \ialign loescht \everycr, bevor \halign beginnt —
% deshalb steht die Zuweisung im ersten \noalign der Tabelle und muss
% \global sein: \noalign oeffnet eine Gruppe.
\newcommand*{\dsa@tabellenlinienan}{%
  \noalign{\global\everycr{\dsa@tabellenlinie}}}

% Die Kastenueberschrift. Der Musterbogen gibt 12 pt, der Kastentext hat
% 9,5 bp auf 11,4 bp -- ein Kasten ist ein eigener Satzraum und folgt nicht
% dem Grundlinienraster der Seite.
%
% Die Titelgrundlinie sitzt dort 5,16 mm unter der Kastenoberkante, der
% Kastentext beginnt bei \dsakastenoben, also 6 mm darunter. Der Titel steht
% damit in der ersten Zeile des Kastens und braucht keine eigene Lage.
\newcommand*{\dsakastentitelgrad}{12}
\newcommand{\dsaKastentitel}[1]{%
  {\bfseries\fontsize{\dsakastentitelgrad bp}{\dsakastendurchschuss bp}%
   \selectfont #1\par}%
  \nobreak}

% ---- Die Tabelle ----
%
% \begin{dsaTabelle}{ll} nimmt dasselbe Spaltenformat wie tabular. Zwei
% Dinge macht die Umgebung daraus:
%
% 1. Sie spannt die Tabelle ueber die volle Spaltenbreite. Ohne das endet
%    die Tabelle dort, wo ihr laengster Eintrag endet, waehrend die
%    Titelleiste ueber die ganze Spalte laeuft — Leiste und Linien standen
%    gemessen 60 pt auseinander. \extracolsep{\fill} verteilt die
%    Restbreite zwischen den Spalten; die aeusseren \hskip halten den
%    Zelleneinzug an beiden Raendern.
% 2. Sie setzt sie in eine Box ohne Hoehe und Tiefe. \begin{tabular} allein
%    genuegt nicht: ohne Positionsargument wird die Tabelle ein \vcenter,
%    dessen Hoehe halbe Tabellenhoehe plus Mathe-Achse ist. Die Box ist
%    damit hoeher als eine Grundlinie, TeX faellt auf \lineskip zurueck, und
%    der Anfang haengt an der Tiefe der letzten Textzeile -- gemessen 0,7 bp
%    neben dem Raster. Mit [t] ist die Referenzgrundlinie die erste
%    Zeilengrundlinie und sitzt genau auf der laufenden Grundlinie; die
%    Zeilen darunter halten ihre 12 bp von selbst. Den Raum liefert
%    \dsaRasterluft, aufgerundet auf ganze Rastereinheiten.
%
% L{<breite>} ist p{<breite>} mit Flattersatz.
%
% Blocksatz in einer schmalen Spalte zieht die Wortabstaende auf: in eine
% p{20mm} passen zwei Woerter je Zeile, und TeX meldet reihenweise
% "Underfull \hbox" -- im Abzug sind das loechrige Zeilen. In so schmalen
% Spalten ist Flattersatz nicht Notloesung, sondern das Richtige.
%
% Ein \raggedright vor dem tabular hilft nicht: eine p-Spalte ist eine
% parbox, und die ruft \@parboxrestore, das \rightskip und \parfillskip
% zurueckdreht. Der Flattersatz muss deshalb in die Spaltenvorschrift.
% \arraybackslash gibt \\ seine Tabellenbedeutung zurueck, die
% \raggedright ueberschreibt.
%
% Die Tiefenstuetze am Zellenende ist hier wirkungslos und steht trotzdem
% da. Im Rastersatz braucht sie niemand: die Zeilenhoehe kommt aus dem
% Raster, und \dsazellstuetze ist 0 pt, also eine Box ohne Hoehe, Tiefe und
% Breite. Gebraucht wird sie in einem Satz ohne Raster: dort folgt die Linie
% unter einer mehrzeiligen Zelle sonst der Unterlaenge des letzten Wortes —
% gemessen bis zu 3,4 bp Unterschied zwischen zwei Zeilen derselben Tabelle.
% So laesst sich der Spaltentyp teilen, statt ihn zu verdoppeln.
\newlength{\dsazellstuetze}\setlength{\dsazellstuetze}{0pt}
\newcommand*{\dsa@zellstuetze}{\rule[-\dsazellstuetze]{0pt}{0pt}}
\newcolumntype{L}[1]{>{\raggedright\arraybackslash}p{#1}<{\dsa@zellstuetze}}

\newsavebox{\dsa@tabelle}
\newenvironment{dsaTabelle}[1]
  {% \linewidth ist in einer p-Spalte die Zellenbreite, nicht die der
   % Spalte. Das Band einer Rubrikzeile waere dort nur so breit wie ihre
   % erste Zelle -- gemessen 24 statt 80,5 mm. Die Breite wird deshalb hier
   % gemerkt, ausserhalb der Tabelle.
   \setlength{\dsa@tabellenbreite}{\linewidth}%
   \begin{lrbox}{\dsa@tabelle}%
   \setlength{\tabcolsep}{\dsatabelleninnen}%
   \setlength{\arrayrulewidth}{\dsatabellenstrich}%
   \dsaTabellenlinie
   \begin{tabular*}{\linewidth}[t]%
     {@{\hskip\dsatabelleninnen\extracolsep{\fill}}#1@{\hskip\dsatabelleninnen}}%
   \dsa@tabellenlinienan}
  {\end{tabular*}\end{lrbox}%
   % \everycr ist global gesetzt und muss global zurueck.
   \global\everycr{}%
   \dsa@tabellesetzen}

\newcommand*{\dsa@tabellesetzen}{%
  \par\nobreak
  \begingroup
    \dimen@=\dimexpr\ht\dsa@tabelle+\dp\dsa@tabelle\relax
    % \numexpr teilt rundend, nicht abschneidend -- der uebliche
    % Ceil-Trick rechnet damit falsch. Also rundend teilen und aufstocken,
    % wenn das Ergebnis nicht reicht. Ein bp Toleranz, weil 12 bp keine
    % ganze Zahl von sp sind.
    \edef\dsa@tabzeilen{\the\numexpr
      \number\dimen@/\number\dimexpr\dsaRaster{1}\relax\relax}%
    \ifdim\dimexpr\dsaRaster{\dsa@tabzeilen}\relax
          <\dimexpr\dimen@-1bp\relax
      \edef\dsa@tabzeilen{\the\numexpr\dsa@tabzeilen+1\relax}%
    \fi
    % Eine Tabelle ist ein Block und wird nicht umbrochen. Passt sie in die
    % laufende Spalte, wandert sie ganz in die naechste; passt sie in keine,
    % laeuft sie unten heraus und die letzten Zeilen fehlen im Abzug. Das
    % faellt beim Lesen des Quelltextes nicht auf, deshalb die Warnung.
    \ifdim\dsaRaster{\dsa@tabzeilen}>\textheight
      \ClassWarning{dsa5latex}{Diese Tabelle ist \dsa@tabzeilen\space
        Rastereinheiten hoch und passt in keine Spalte (\the\textheight).
        Sie laeuft unten aus der Spalte heraus. In mehrere dsaTabelle
        aufteilen und den Kopf wiederholen}%
    \fi
    % Die Box so heben, dass ihre erste TEXTgrundlinie auf der laufenden
    % Grundlinie liegt.
    %
    % Bei tabular[t] ist die Referenzgrundlinie die der ersten Reihe. Steht
    % dort eine \hline, ist diese Reihe die Linie, ihre Hoehe also
    % \arrayrulewidth statt 0,7\baselineskip, und die erste Textzeile liegt
    % eine Zeilenhoehe tiefer. Gemessen waren das 8,8 bp.
    %
    % Eine Box mit weniger als einer halben Zeilenhoehe hat oben eine Linie
    % und keine Textzeile -- daran ist der Fall zu erkennen. Gemessen ist
    % ihr \ht dann 0,0 pt: die Linie liegt vollstaendig unter der
    % Referenzgrundlinie, und die erste Textgrundlinie folgt erst nach
    % Linienstaerke plus Strutshoehe.
    \ifdim\ht\dsa@tabelle<0.5\baselineskip
      \dimen2=\dimexpr\ht\strutbox+\arrayrulewidth\relax
    \else
      \dimen2=\z@
    \fi
    \noindent
    \makebox[\linewidth][l]{%
      \raisebox{\dimen2}[0pt][0pt]{\usebox{\dsa@tabelle}}}%
    \par
    % Eine Einheit weniger: die erste Zeile sitzt schon auf der laufenden
    % Grundlinie, und der Text danach kommt seinen Durchschuss spaeter.
    \dsaRasterluft{\the\numexpr\dsa@tabzeilen-1\relax}%
  \endgroup
  \nobreak}

% Kein \extrarowheight. Am gesetzten Ergebnis nachgemessen stehen die
% Grundlinien einer Tabelle ohne Zutun genau 12 bp auseinander — mit 2 bp
% Zugabe waren es 14, und die Tabelle lief aus dem Raster. Wer die Zeilen
% luftiger braucht, nimmt ein Vielfaches von 12 bp, nicht irgendeinen Wert;
% das Band der Titel- und Rubrikzeilen bleibt dabei eine Rastereinheit hoch.
\newlength{\dsatabellenluft}\setlength{\dsatabellenluft}{0bp}
\AtBeginDocument{\setlength{\extrarowheight}{\dsatabellenluft}}

%%% ==================================================================
%%% 18  Seitentypen
%%% ==================================================================

% ---- Umschlag vorne ----
% umschlag-vorne ist 216,0 x 303,0 mm — A4 plus 3 mm auf allen vier Seiten.
% Der Covertitel ist Gestaltung, nicht Mass — deshalb alles einstellbar.
%
% Der Baukasten fuehrt fuer die Formatvorlage „DSA Cover Vordergrund" 28 pt.
% Das ist der Wert der Wordvorlage, nicht der des gesetzten Umschlags: die
% Textebene „Abenteuertitel" in Cover_Buchtitel.psd traegt FontSize 75 bei
% einer Ebenentransformation von 2,3776, also 178,3 px, und Leading 90, also
% 213,3 px. Bei 300 ppi sind das 42,8 pt Schriftgrad und 51,2 pt
% Zeilenabstand — der Durchschuss ist damit das Uebliche 1,2fache.
\newcommand*{\dsatitelgrad}{42.8}        % Schriftgrad in pt, aus dem PSD
\newcommand*{\dsatiteldurchschuss}{51.4} % Zeilenabstand in pt, 1,2fach
% Die Kontur des Schriftzugs, der helle Saum. Das PSD gibt 3 px, also
% 0,72 pt bei 300 ppi. Voreinstellung hier ist 1 px = 0,24 pt: die feine
% Linie, nicht der breite Saum. Aendern mit \dsaTitelKontur.
\newcommand*{\dsatitelkonturmass}{0.24}  % Breite des hellen Rands in pt
\newlength{\dsatitelzeileeins} \setlength{\dsatitelzeileeins}{55mm}
\newlength{\dsatitelzeilezwei} \setlength{\dsatitelzeilezwei}{77mm}

% Der Covertitel, nachgebildet nach Cover_Buchtitel.psd aus dem Baukasten.
% Ausgelesen mit psd-tools; die Ebene „Abenteuertitel" traegt vier Effekte,
% und unter ihr liegt eine eigene Ebene „Rahmen":
%
%   Rahmen (Flaeche in Titelform, 1434 x 325 px zu 1364 x 126 px Text,
%           also 35 px ueber den Text hinaus)
%     Flaechenfarbe 2E2832, Kontur 3 px mit Verlauf A6A6A6 nach 2B2630,
%     Schlagschatten 21 px Abstand, 21 px Weichzeichnung, 75 Prozent, 120 Grad
%   Abenteuertitel
%     Verlauf senkrecht C5B8CE nach 28232D, 42 Prozent Skalierung,
%       9 Prozent nach oben versetzt
%     Schein aussen 341811, 51 px Weichzeichnung, 100 Prozent
%     Kontur 3 px, Verlauf A6A6A6 nach 2B2630 — oben hell, unten dunkel
%     Schlagschatten 31 px Abstand, 18 px Weichzeichnung, 63 Prozent
%
% Das PSD ist 300 ppi, also 1 px = 0,24 pt. Die Radien unten sind daraus
% umgerechnete Absolutwerte und gelten fuer den Schriftgrad des PSD, 42,8 pt.
% Wer den Titel deutlich groesser setzt, skaliert sie mit.
%
% Die Ebene „Rahmen" ist auf den Beispieltitel des Baukastens zugeschnitten
% und als Grafik unbrauchbar. Ihr Alpha ist ein Block mit harter Kante,
% 35 px um die Textbox. Nachgebaut wird sie hier nicht als Block, sondern als
% Silhouette des eigenen Schriftzugs, gleichmaessig um denselben Abstand
% aufgeblaeht: ein Block waere fuer jeden Titel neu zu zeichnen, die
% Silhouette passt sich an. Die Kante ist wie im PSD hart, der Schlagschatten
% ist dieselbe Silhouette, versetzt. Der Schein aussen (341811, 51 px) faellt
% weg: auf der deckenden Flaeche ist er nicht zu sehen.
%
% Mit \dsaTitelVerlaufAus wird stattdessen schlicht weiss mit Kontur gesetzt.
\newif\ifdsa@titelverlauf \dsa@titelverlauftrue
\newcommand*{\dsaTitelVerlaufAn}{\dsa@titelverlauftrue}
\newcommand*{\dsaTitelVerlaufAus}{\dsa@titelverlauffalse}

\definecolor{dsatitelhell}{HTML}{C5B8CE}    % Verlauf oben
% Verlauf unten. Das PSD gibt 28232D — praktisch die Farbe der Flaeche
% darunter (2E2832). In Photoshop trennt die weichgezeichnete Kontur beides;
% ohne sie klebt der Schriftzug an der Flaeche, deshalb hier etwas heller.
\definecolor{dsatiteldunkel}{HTML}{3A3442}  % Verlauf unten
\definecolor{dsatitelflaeche}{HTML}{2E2832} % Ebene „Rahmen"
\definecolor{dsatitelkante}{HTML}{A6A6A6}   % Kontur, Lichtkante
% Beide Schlagschatten. Das PSD nennt keine Farbe, also die Voreinstellung
% von Photoshop: Schwarz, Modus Multiplizieren. Auf einem Bild ist
% Multiplizieren mit Schwarz dasselbe wie Deckend mit Schwarz, deshalb
% braucht es hier keinen Mischmodus.
\definecolor{dsatitelschatten}{HTML}{000000}

% Die rote Fassung desselben Titels, wie veroeffentlichte Hefte sie tragen.
% Sie steht NICHT im Baukasten — Cover_Buchtitel.psd kennt nur die graue —,
% sondern ist am Umschlag des „Aufsteller-Sets fuer Das Schwarze Auge"
% (Ulisses Spiele, US25533PDF, Seite 1, Schriftzug „AUFSTELLER SET")
% gemessen: mit pdftoppm in 300 ppi ausgegeben und pixelweise abgetastet.
% Die Herleitung jedes Werts steht in doku/MASSE.md, Abschnitt 4, „Der rote
% Covertitel"; weil die Quelle ein Heft ist und nicht der Baukasten, steht
% sie dort eigens abgegrenzt.
%
% Die Flaeche ist deckend, nicht durchscheinend: an 21 Spalten quer ueber
% ihre obere Kante zeigt sie innen denselben Ton, gleichgueltig wie hell der
% Umschlag darunter ist (aussen 14 bis 90 in Rot, innen durchweg 88 bis 103).
%
% In der Vorlage wird sie zur Schrift hin dunkler, auf etwa 250600. Das ist
% der fuenfte Effekt des PSD, der Schein aussen (341811, 51 px), den diese
% Klasse nicht zeichnet; hier steht die Flaeche einfarbig auf dem Wert an
% der Kante. Naeheres in doku/PRUEFPLAN.md.
\definecolor{dsatitelrothell}{HTML}{B22526}    % Verlauf oben
\definecolor{dsatitelrotdunkel}{HTML}{741C16}  % Verlauf unten
\definecolor{dsatitelrotflaeche}{HTML}{5F1812} % Ebene „Rahmen"
\definecolor{dsatitelrotkante}{HTML}{C08848}   % Kontur, hier ein Gold

% Masse in pt, aus dem PSD umgerechnet (300 ppi, 1 px = 0,24 pt).
%
% Die Flaeche haelt 35 px = 8,4 pt Abstand zur Schrift, auf allen Seiten
% gleich.
%
% Ihren Schlagschatten — im PSD 21 px Abstand unter 120 Grad, 21 px
% Weichzeichnung, 75 Prozent — gibt es hier auch, weichgezeichnet ueber
% gestaffelte Lagen; siehe „Die beiden Schlagschatten" weiter unten. Ein
% harter Versatz taugte dafuer nicht: davon blieb eine zweite, scharf
% begrenzte Silhouette, und die las sich als Schlagschatten des Schriftzugs
% statt als Schatten einer Flaeche.
% 8,4 pt sind die 35 px des PSD, und dabei bleibt es. Hier standen eine
% Zeit lang 13 pt, damit die Flaechen zweier Zeilen sicher ineinanderlaufen:
% bei 42,8 pt Zeilenabstand und rund 31 pt hoher Tinte bleiben 11,8 pt Luft
% zwischen den Zeilen, in denen sich zwei Raender von je 13 pt um 14 pt
% ueberlappen. Nachgemessen ist das zu breit. An zwei gesetzten Abenteuern,
% Umschlag in 300 ppi, quer durch die Buchstabenstaemme geschnitten, jeweils
% im Verhaeltnis zur Versalhoehe — nur so sind verschiedene Grade
% vergleichbar:
%
%   Ketten fuer die Ewigkeit, Zeile 1   29,5 pt Versal,  8,9 pt Rand   0,30
%   Ketten fuer die Ewigkeit, Zeile 2   39,4 pt Versal, 13,2 pt Rand   0,34
%   Schrecken aus der Tiefe, Zeile 1    39,4 pt Versal,  8,9 pt Rand   0,23
%   PSD des Baukastens                  28,5 pt Versal,  8,4 pt Rand   0,29
%   diese Klasse mit 13 pt              28,5 pt Versal, 13,0 pt Rand   0,46
%
% Der Verlag liegt bei 0,23 bis 0,34, der Baukasten mittendrin bei 0,29 —
% die 13 pt lagen mit 0,46 weit darueber und lasen sich als klobige Platte.
% Bei grossen Graden faellt das doppelt auf, weil der Rand mitskaliert: auf
% einer Thumbnail-Titelseite in 88 pt wurden daraus 26,7 pt.
%
% Dass zwei Zeilen damit nicht mehr sicher zu einem Block zusammenlaufen,
% ist kein Verlust: die Verlagsumschlaege setzen ihre Zeilen enger, statt
% den Rand zu verbreitern (gemessen 12,7 pt Luft zwischen der Grundlinie
% oben und der Versalhoehe unten, rund 0,35 der Versalhoehe). Wer den Block
% will, rueckt die Zeilen zusammen — \dsaTitelZeilenfaktor{0.9} —, nicht
% den Rand auf.
\newcommand*{\dsatitelrand}{8.4}          % Abstand der Flaeche zur Schrift
\newcommand*{\dsatitelflaechenstufen}{5}  % Radienstufen der Flaeche
% Die Flaeche folgt der Schrift, also auch ihren Oberlaengen — und die reichen
% weiter nach oben, als die Grundlinie nach unten reicht. Ohne Ausgleich
% steht deshalb oben deutlich mehr Flaeche als unten, und der Schriftzug
% sitzt zu tief darin. Dieser Versatz nach unten gleicht es aus.
%
% Kein Mass aus dem PSD, sondern am eigenen Ergebnis gemessen: Flaeche ueber
% ihre Farbe und Schrift ueber ihre Helligkeit getrennt, an zwei Punkten:
%
%   Versatz 0 pt   Rand oben 18,72 pt   unten  6,00 pt
%   Versatz 6 pt   Rand oben 12,72 pt   unten 12,00 pt
%
% Der Wert haengt am Text: Zeilen mit Unterlaengen brauchen weniger, eine
% Zeile in Versalien mehr. 6,4 pt passt fuer einen zweizeiligen Titel aus
% gemischten Buchstaben.
\newcommand*{\dsatitelflaechetiefer}{6.4bp}
%
% Wie glatt der Rand der Flaeche wird, haengt am Abstand zweier Nachbarkopien
% auf dem \contour-Kreis: liegt er unter der Strichstaerke des duennsten
% Buchstabenzugs, verschmelzen die Kopien und der Rand ist glatt; darueber
% perlt er aus. 0,6 pt ist bei Andalus in 42,8 pt sicher, kostet aber bei
% 11 pt Radius schon 116 Kopien.
%
% Diese Zahl braucht nur die AEUSSERSTE Lage. Die inneren fuellen die Luecke
% zwischen Kopienring und Schrift und duerfen grob bleiben.
\newcommand*{\dsatitelperlabstand}{0.6}
\newcommand*{\dsatitelkopieninnen}{16}

% ---- Die beiden Schlagschatten ----
%
% Im PSD traegt jede der beiden Ebenen einen weichgezeichneten Schlagschatten:
%
%   Rahmen          21 px Abstand, 21 px Weichzeichnung, 75 Prozent, 120 Grad
%   Abenteuertitel  31 px Abstand, 18 px Weichzeichnung, 63 Prozent
%
% Bei 300 ppi sind das 5,04 bp Abstand bei 5,04 bp Weichzeichnung und
% 7,44 bp bei 4,32 bp. Ein Winkel steht nur beim Schatten der Flaeche; der
% Schriftschatten uebernimmt ihn, weil Photoshop den Lichtwinkel per
% Voreinstellung global fuehrt und beide Ebenen aus demselben Dokument
% stammen.
%
% Richtung: Photoshop zaehlt den Winkel als die Richtung, AUS der das Licht
% kommt, der Schatten faellt entgegengesetzt. Also dx = -Abstand*cos(Winkel),
% dy = -Abstand*sin(Winkel); bei 120 Grad ist das nach rechts unten.
%
% Weichzeichnung ohne Weichzeichner: die Silhouette wird mehrfach
% uebereinandergelegt, von aussen nach innen mit fallendem Radius und
% steigender Deckkraft. Lage j von aussen soll kumuliert auf
% Deckkraft*j/Lagen kommen, also traegt sie selbst
%
%   a_j = 1 - (1 - D*j/L) / (1 - D*(j-1)/L)
%
% bei; das ergibt einen linearen Abfall von der vollen Deckkraft an der
% harten Kante auf null am aeusseren Rand. Ein Gaussprofil waere naeher am
% PSD, aber der Unterschied verschwindet hinter einem Schriftzug.
%
% Jede Lage muss dabei in eine PDF-Transparenzgruppe: die 100 und mehr
% \contour-Kopien einer Lage ueberlappen einander, und ohne Gruppe
% multipliziert sich ihre Teildeckung an jeder Ueberlappung auf. Der Schatten
% waere dann in der Mitte fast deckend und am Rand fleckig.
% Der Lichtwinkel. Das PSD sagt 120 Grad, die gesetzten Hefte sagen etwas
% anderes — siehe die Messung weiter unten bei \dsatitelschriftschattenweg.
% Hier steht der Wert der Hefte, weil er das Bild traegt: bei 120 Grad faellt
% der Schatten steil nach unten und liest sich als zweite Zeile unter der
% Schrift, bei 150 Grad flach zur Seite und liest sich als Kante. Der Winkel
% gilt fuer BEIDE Schatten, so wie Photoshop sein Licht global fuehrt.
\newcommand*{\dsatitelschattenwinkel}{150}
% Sechzehn Lagen. Am 600-ppi-Auszug des Schriftschattens verglichen: bei
% acht laufen noch Wellen durch den Saum, bei sechzehn nicht mehr, und
% zwischen sechzehn und vierundzwanzig ist kein Unterschied zu sehen.
%
% Der Perlabstand ist derselbe feine wie an der Flaeche. Ein groeberer waere
% billiger, legt aber einen Kranz Perlen um den weichsten Teil des Schattens.
% Billiger heisst hier ohnehin wenig: gemessen kosten beide Schatten bei zwei
% Zeilen in 88 pt rund anderthalb Sekunden, bei 42,8 pt eine halbe. Neben den
% Seitenhintergruenden faellt das nicht auf.
%
% Wers beim Schreiben trotzdem eilig hat, nimmt die Klassenoption „entwurf".
% Sie setzt hier vier Lagen und den vierfachen Abstand — dann ist der
% Schatten ein grober Fleck, aber er sitzt an derselben Stelle. Dieselbe
% Option ersetzt auch schon die Bilder durch Rahmen.
\newcommand*{\dsatitelschattenlagen}{16}
\newcommand*{\dsatitelschattenperlabstand}{0.6}
\ifdsa@entwurf
  \renewcommand*{\dsatitelschattenlagen}{4}
  \renewcommand*{\dsatitelschattenperlabstand}{2.4}
\fi
\newcommand*{\dsatitelflaechenschattenweg}{5.04}
\newcommand*{\dsatitelflaechenschattenweich}{5.04}
\newcommand*{\dsatitelflaechenschattendeckung}{0.75}
% Weg und Weichzeichnung des Schriftschattens stehen im PSD auf 31 px und
% 18 px, bei 300 ppi also 7,44 und 4,32 bp. Hier stehen die Werte der
% gesetzten Hefte, gemessen an den Umschlaegen von US25324 und US25326 in
% 300 ppi — ueber die Kreuzkorrelation zwischen Schriftmaske und
% Dunkelheitsbild, denn der Schatten ist eine weichgezeichnete Kopie des
% Schriftzugs und die Korrelation findet ihr Maximum genau auf seinem
% Versatz. Alles im Verhaeltnis zur Versalhoehe, weil die Grade verschieden
% sind:
%
%                              dx      dy    Laenge   je Versalhoehe  Winkel
%   Ketten, Zeile 1          5,5 pt  5,8 pt   8,0 pt      0,270        133
%   Ketten, Zeile 2          8,4 pt  4,6 pt   9,6 pt      0,243        151
%   Schrecken, Zeile 1       8,4 pt  4,8 pt   9,7 pt      0,246        150
%   diese Klasse mit 7,44    8,6 pt 13,0 pt  15,6 pt      0,315        124
%
% Dieselbe Messung an der eigenen Ausgabe gibt 0,315, wo die Klasse nominal
% 7,44/28,5 = 0,261 setzt: die Korrelation zieht das Maximum um den Faktor
% 1,21 nach aussen, weil der Teil des Schattens, der unter den Buchstaben
% liegt, nicht zu sehen ist. Um denselben Faktor bereinigt ergeben die
% 0,253 der Hefte (Mittel der drei Zeilen) 0,209 der Versalhoehe, und bei
% 28,5 pt Versalhoehe zum Bezugsgrad 42,8 pt sind das 6,0 bp.
%
% Die Weichzeichnung traegt diese Verzerrung nicht: quer durch einen
% Buchstabenstamm gemessen reicht die dunkle Zone bei den Heften 0,237 der
% Versalhoehe weit, in dieser Klasse 0,141 bei nominal 4,32/28,5 = 0,152.
% 0,237 x 28,5 pt sind die 6,8 bp unten.
%
% Warum ueberhaupt die Hefte und nicht das PSD: mit dem Rand der Flaeche auf
% seinen 8,4 pt (siehe \dsatitelrand) passt der lange, steile Schatten des
% PSD nicht mehr unter die Flaeche — er laeuft ueber ihre Kante hinaus aufs
% Titelbild. Die Hefte loesen das nicht mit einer breiteren Flaeche, sondern
% mit einem kuerzeren, flacheren und weicheren Schatten.
\newcommand*{\dsatitelschriftschattenweg}{6.0}
\newcommand*{\dsatitelschriftschattenweich}{6.8}
\newcommand*{\dsatitelschriftschattendeckung}{0.63}
\newif\ifdsa@titelschatten \dsa@titelschattentrue

% Der Verlauf laeuft nicht ueber die ganze Zeilenhoehe: Photoshop skaliert ihn
% auf 42 Prozent und versetzt ihn nach unten. Darunter bleibt es durchgehend
% dunkel, darueber durchgehend hell. Nachgebildet als Schattierung mit vier
% Haltepunkten; die 100 bp sind eine Bezugshoehe, \shade skaliert sie auf die
% Hoehe der Zeile.
% In ein Makro gefasst, weil die beiden Farben einstellbar sind: pgf wertet
% die Farbnamen beim DEKLARIEREN aus, nicht beim Zeichnen. Ein spaeteres
% \colorlet auf dsatitelhell kaeme in der Schattierung nicht an, sie bliebe
% grau. Die Stellbefehle legen sie deshalb neu an.
\newcommand*{\dsa@titelverlaufneu}{%
  \pgfdeclareverticalshading{dsatitelverlauf}{100bp}{%
    color(0bp)=(dsatiteldunkel); color(15bp)=(dsatiteldunkel);
    color(78bp)=(dsatitelhell);  color(100bp)=(dsatitelhell)}}
\dsa@titelverlaufneu

% Die beiden Lagen hinter dem Schriftzug einzeln schaltbar: der duenne Rahmen
% (die Kontur des Schriftzugs) und die grosse Flaeche (die Ebene „Rahmen").
\newif\ifdsa@titelrahmen  \dsa@titelrahmentrue
\newif\ifdsa@titelflaeche \dsa@titelflaechetrue
\newcommand*{\dsaTitelRahmenAus}{\dsa@titelrahmenfalse}
\newcommand*{\dsaTitelFlaecheAus}{\dsa@titelflaechefalse}
\newcommand*{\dsaTitelSchattenAus}{\dsa@titelschattenfalse}
\newcommand*{\dsaTitelSchattenAn}{\dsa@titelschattentrue}

% Der Bezugsgrad, auf den sich alle Masse des Rahmens beziehen: der Grad der
% PSD-Ebene. Eine Zeile in einem anderen Grad skaliert sie im Verhaeltnis.
\newcommand*{\dsatitelbezugsgrad}{42.8}

\newcommand*{\dsa@titelschrift}{%
  \dsaandalus\fontsize{\dsatitelgrad bp}{\dsatiteldurchschuss bp}\selectfont\bfseries}
% Dieselbe Schrift in einem beliebigen Grad. Der Durchschuss ist gleich dem
% Grad, weil jede Titelzeile fuer sich gesetzt wird.
\newcommand{\dsa@titelschriftgrad}[1]{%
  \dsaandalus\fontsize{#1}{#1}\selectfont\bfseries}

% WICHTIG: kein text width und kein align an den Titelknoten. Mit text width
% setzt TikZ den Inhalt als echten Absatz, und dort verliert \contour beim
% mehrfachen Setzen die Leerzeichen — aus „Der falsche" wird „Derfalsche".
% Ohne text width steckt der Text in einer Box und bleibt heil. Die Zeilen
% sind einzeilig, text width braucht es also nicht.

% Eine geschlossene Flaeche in der Form des Schriftzugs, um #3 pt aufgeblaeht.
% \contour setzt Kopien auf einem Kreis vom Radius #3; eine einzelne Lage gibt
% deshalb nur einen Ring und laesst zwischen Ring und Schrift Luecken. #4 sagt,
% in wie vielen Stufen der Radius durchlaufen wird: eine Stufe genuegt fuer
% einen Saumring, drei fuellen bis zur Schrift durch.
%
% #1 Ankerkoordinate  #2 Farbe  #3 Radius in pt  #4 Stufen
% #5 Schriftgrad  #6 Text
\newlength{\dsa@titelradius}
\newlength{\dsa@titeltiefer}
\newlength{\dsa@titelschattenx}
\newlength{\dsa@titelschatteny}
\newcommand{\dsa@titelform}[6]{%
  \foreach \dsa@k in {1,...,#4}{%
    \pgfmathsetlength{\dsa@titelradius}{#3bp*\dsa@k/#4}%
    % Kopienzahl: nur die aeusserste Lage braucht so viele, dass zwei
    % Nachbarkopien \dsatitelperlabstand nicht ueberschreiten.
    \ifnum\dsa@k=#4\relax
      \pgfmathtruncatemacro{\dsa@kopien}%
        {max(\dsatitelkopieninnen,
             ceil(6.2832*#3/\dsatitelperlabstand))}%
    \else
      \pgfmathtruncatemacro{\dsa@kopien}{\dsatitelkopieninnen}%
    \fi
    \node[anchor=center, inner sep=1pt] at (#1)
      {\dsa@titelschriftgrad{#5}%
       \contourlength{\dsa@titelradius}\contournumber{\dsa@kopien}%
       \contour{#2}{\textcolor{#2}{#6}}};}}

% Ein weichgezeichneter Schlagschatten in der Form des Schriftzugs: dieselbe
% Silhouette wie oben, aber mehrfach uebereinander, von aussen nach innen mit
% fallendem Radius und steigender Teildeckung. Die Rechnung dahinter steht
% oben bei den Massen.
%
% Nur die innerste Lage wird flaechig gefuellt (Stufen #6); die aeusseren
% duerfen Ringe bleiben, denn zwischen zwei Lagen liegen nur
% Weichzeichnung/Lagen Punkte, und so viel ueberlappt jeder Buchstabenzug.
%
% #1 Ankerkoordinate, Versatz schon eingerechnet
% #2 Grundradius in bp — die harte Kante der Vorlage
% #3 Weichzeichnung in bp  #4 Deckkraft 0..1
% #5 Schriftgrad  #6 Stufen der innersten Lage  #7 Text
% Das Profil des Saums: welchen Anteil der Deckung der Schatten im Abstand x
% von der harten Kante noch hat, x von 0 (Kante) bis 1 (aussen). Photoshop
% zeichnet eine Gausskante, keine Rampe — der Unterschied ist der lange
% Ausklang aussen, und genau der macht den Schatten weich statt gestuft.
% exp(-2,5) wird abgezogen und herausgerechnet, damit das Profil bei x = 1
% wirklich auf null geht und der Schatten keine Abbruchkante bekommt.
\newcommand{\dsa@titelprofil}[1]{(exp(-2.5*(#1)*(#1))-0.082085)/0.917915}

\newcommand{\dsa@titelschatten}[7]{%
  \begin{scope}
    \pgfmathtruncatemacro{\dsa@titellagen}{\dsatitelschattenlagen}%
    \foreach \dsa@j in {1,...,\dsa@titellagen}{%
      % Der Saum reicht die volle Weichzeichnung weit nach aussen. Eine
      % Gausskante laeuft eigentlich um die harte Kante herum, halb nach
      % innen und halb nach aussen — die innere Haelfte kann \contour aber
      % nicht, es blaeht auf und schrumpft nicht. Also traegt die innerste
      % Lage die volle Deckung auf der harten Kante, und der ganze Verlauf
      % liegt darueber. Mit der halben Spanne wurde der Schatten sichtbar
      % haerter als der im PSD.
      \pgfmathsetmacro{\dsa@titelschattenr}%
        {#2 + #3*(\dsa@titellagen-\dsa@j)/\dsa@titellagen}%
      % Kumulierte Deckung dieser und aller Lagen darueber, und daraus, was
      % die Lage selbst beitragen muss.
      \pgfmathsetmacro{\dsa@titelschattenvor}%
        {#4*\dsa@titelprofil{(\dsa@titellagen-\dsa@j+1)/\dsa@titellagen}}%
      \pgfmathsetmacro{\dsa@titelschattennun}%
        {#4*\dsa@titelprofil{(\dsa@titellagen-\dsa@j)/\dsa@titellagen}}%
      \pgfmathsetmacro{\dsa@titelschattena}%
        {1 - (1-\dsa@titelschattennun)/(1-\dsa@titelschattenvor)}%
      % Der Perlabstand bleibt in jeder Lage derselbe wie an der Flaeche.
      % Ihn mit der Deckung wachsen zu lassen — die aeussere Lage ist ja nur
      % ein Achtel so kontrastreich wie die innerste — halbiert zwar die
      % Kopienzahl und damit den Lauf, legt aber einen sichtbaren Kranz
      % Perlen um den weichsten Teil des Schattens. Der Umschlag ist eine
      % Seite je Dokument; er darf dauern.
      %
      % Gilt nur bis zum Ende dieses scope und laesst die Kontur des
      % Schriftzugs, die spaeter kommt, bei ihrem eigenen Abstand.
      \begin{scope}[transparency group, opacity=\dsa@titelschattena]
        \let\dsatitelperlabstand\dsatitelschattenperlabstand
        \ifnum\dsa@j=\dsa@titellagen\relax
          \dsa@titelform{#1}{dsatitelschatten}{\dsa@titelschattenr}%
                        {#6}{#5}{#7}%
        \else
          \dsa@titelform{#1}{dsatitelschatten}{\dsa@titelschattenr}%
                        {1}{#5}{#7}%
        \fi
      \end{scope}}%
  \end{scope}}

% Der Verlauf entsteht NICHT ueber ein pgf-Fading. Das waere der naheliegende
% Weg, laesst sich aber nicht verlaesslich auf den Schriftzug ausrichten:
% „fit fading" skaliert die Fadingbox auf die Pfadbox, und beide stimmen nicht
% ueberein, sobald eine Kontur im Spiel ist. Drei Anlaeufe, drei Versaetze.
%
% Stattdessen: den Schriftzug mehrfach zeichnen, jedes Mal auf einen
% waagerechten Streifen beschnitten und in einer anderen Farbe. Beschneiden
% auf ein Rechteck ist in TikZ exakt. Kontur und Fuellung entstehen im selben
% Streifen, damit beide demselben Verlauf folgen — im PSD hat auch die Kontur
% einen: oben hell, unten dunkel. Ohne diese Lichtkante verschwindet der
% Schriftzug in der dunklen Flaeche.
%
% Wird DIREKT in eine bestehende tikzpicture gezeichnet, nicht in einen
% Knoten. Eine verschachtelte tikzpicture waere naheliegender, aber die
% inneren \clip-Pfade veraendern deren Begrenzungsrahmen und verschieben
% dadurch die Ausrichtung gegen die Kontur.
%
% Reihenfolge von hinten nach vorn:
%   1 der Saum, aussen nach innen immer deckender
%   2 der deckende Kern der Flaeche
%   3 je Streifen die Kontur, dann die Fuellung
%
% #1 Name des Fadings, je Zeile ein eigenes  #2 Koordinate
% #3 Schriftgrad in pt  #4 Text
%
% Gezeichnet wird in einer eigenen tikzpicture, deren Bezugsknoten im
% Ursprung sitzt. Nur so trifft ein unskaliertes Fading den Schriftzug:
% „fit fading=false" legt es um den Ursprung, ohne es auf die Pfadbox zu
% ziehen. Der Begrenzungsrahmen wird auf die Textbox festgelegt, damit die
% Zeile an ihrer Grundlinie haengt und nicht am Saum.
%
% Zum Namen des Fadings: \pgfdeclarefading nimmt ihn unexpandiert,
% „path fading" expandiert ihn. Ein Zaehlermakro im Namen laesst die
% Referenz deshalb ins Leere greifen, ohne Fehlermeldung, und pgf benutzt
% still das zuletzt gesetzte Fading. Deshalb wird der Name mit \edef
% ausgeschrieben, bevor er hierher kommt.
%
% Reihenfolge von hinten nach vorn, wie im PSD:
%   1 der Schlagschatten der Flaeche
%   2 die Flaeche in der Form des Schriftzugs
%   3 der Schlagschatten des Schriftzugs, auf der Flaeche
%   4 der helle Rand: die Kontur des Schriftzugs
%   5 der Verlauf in der Schrift
% Gezeichnet wird in VIER STUFEN, und zwar ueber alle Zeilen hinweg: erst
% alle Flaechenschatten (1), dann alle Flaechen (2), dann alle
% Schriftschatten (3), dann alle Lettern (4). Nicht Zeile fuer Zeile mit
% allen fuenf Lagen — und auch nicht „Flaeche samt Schatten" als eine
% Stufe: dann faellt der Schatten der unteren Flaeche auf die obere und
% legt ein dunkles, geschupptes Band zwischen die Zeilen. Jede Lage gehoert
% ueber ALLE Zeilen gezogen, bevor die naechste kommt.
%
% Der Grund ist die Ueberlappung zweier Zeilen. Die Flaeche einer Zeile
% reicht \dsatitelrand ueber ihre Tinte hinaus, und bei den engen
% Zeilenabstaenden der Vorlage greift sie in die Nachbarzeile: bei 88 pt
% oben, 78 pt unten und Zeilenfaktor 0,9 gemessene 12,2 pt tiefer, als die
% Versalien der unteren Zeile beginnen. Zeile fuer Zeile gezeichnet legt
% sich die Flaeche der UNTEREN Zeile dann ueber den Schriftschatten der
% oberen und schneidet ihn an einer waagerechten Kante ab. Die Reihenfolge
% umzudrehen hilft nicht, dann verdeckt die Flaeche der oberen Zeile die
% Oberkante der unteren Versalien — auch gemessen, dieselben 12,2 pt.
%
% Das PSD hat dieses Problem nicht: dort ist die Ebene „Rahmen" EINE Flaeche
% unter dem ganzen Titelblock, und die Textebene mit ihren Effekten liegt
% als Ganzes darueber. Genau das bilden die Stufen ab.
%
% \dsa@titelzeileAn{Fading}{Stufe}{Koordinate}{Grad}{Text}
\newcommand{\dsa@titelzeileAn}[5]{%
  % Alle Masse gelten fuer \dsatitelbezugsgrad und skalieren mit dem Grad
  % dieser Zeile.
  \pgfmathsetmacro{\dsa@titelskala}{#4/\dsatitelbezugsgrad}%
  \pgfmathsetmacro{\dsa@titelrandjetzt}{\dsatitelrand*\dsa@titelskala}%
  % Die Versaetze gehoeren an die Ankerkoordinaten, nicht an einen scope:
  % TikZ-Knoten sind transformationsinvariant, ein scope-shift laesst sie
  % stehen. Erst als Teil der Koordinate wirkt der Versatz.
  \pgfmathsetlength{\dsa@titeltiefer}%
                   {\dsa@titelskala*\dsatitelflaechetiefer}%

  \node[anchor=south, inner sep=0] at (#3){%
    \begin{tikzpicture}
      % Der unsichtbare Bezugsknoten und der Begrenzungsrahmen entstehen in
      % jeder Stufe neu und identisch — nur so sitzen die drei Knoten einer
      % Zeile genau uebereinander.
      \node[anchor=center, inner sep=1pt, opacity=0] (dsa@tzk)
        {\dsa@titelschriftgrad{#4}#5};
      \path[use as bounding box]
        (dsa@tzk.south west) rectangle (dsa@tzk.north east);
      \ifdsa@titelverlauf
        \ifnum#2=1\relax
          \ifdsa@titelflaeche
            \ifdsa@titelschatten
              % 1 der Schlagschatten der Flaeche. Er folgt der Flaeche, traegt
              % ihren Versatz nach unten also mit.
              \pgfmathsetlength{\dsa@titelschattenx}%
                {-\dsa@titelskala*\dsatitelflaechenschattenweg*1bp
                  *cos(\dsatitelschattenwinkel)}%
              \pgfmathsetlength{\dsa@titelschatteny}%
                {-\dsa@titelskala*\dsatitelflaechenschattenweg*1bp
                  *sin(\dsatitelschattenwinkel) - \dsa@titeltiefer}%
              \pgfmathsetmacro{\dsa@titelweich}%
                {\dsa@titelskala*\dsatitelflaechenschattenweich}%
              \dsa@titelschatten
                {[shift={(\dsa@titelschattenx,\dsa@titelschatteny)}]%
                 dsa@tzk.center}%
                {\dsa@titelrandjetzt}{\dsa@titelweich}%
                {\dsatitelflaechenschattendeckung}{#4}%
                {\dsatitelflaechenstufen}{#5}%
            \fi
          \fi
        \fi
        \ifnum#2=2\relax
          \ifdsa@titelflaeche
            % 2 die Flaeche, gleichmaessig aufgeblaeht, harte Kante
            \dsa@titelform{[shift={(0pt,-\dsa@titeltiefer)}]dsa@tzk.center}%
                          {dsatitelflaeche}{\dsa@titelrandjetzt}%
                          {\dsatitelflaechenstufen}{#4}{#5}%
          \fi
        \fi
        \ifnum#2=3\relax
          \ifdsa@titelschatten
            % 3 der Schlagschatten des Schriftzugs. Er liegt auf der Flaeche,
            % nicht darunter — im PSD ist es der Effekt der oberen Ebene. Sein
            % Grundradius ist null: die Vorlage ist der Schriftzug selbst.
            \pgfmathsetlength{\dsa@titelschattenx}%
              {-\dsa@titelskala*\dsatitelschriftschattenweg*1bp
                *cos(\dsatitelschattenwinkel)}%
            \pgfmathsetlength{\dsa@titelschatteny}%
              {-\dsa@titelskala*\dsatitelschriftschattenweg*1bp
                *sin(\dsatitelschattenwinkel)}%
            \pgfmathsetmacro{\dsa@titelweich}%
              {\dsa@titelskala*\dsatitelschriftschattenweich}%
            \dsa@titelschatten
              {[shift={(\dsa@titelschattenx,\dsa@titelschatteny)}]%
               dsa@tzk.center}%
              {0}{\dsa@titelweich}{\dsatitelschriftschattendeckung}{#4}%
              {1}{#5}%
          \fi
        \fi
        \ifnum#2=4\relax
          \ifdsa@titelrahmen
            % 4 der helle Rand um den Schriftzug, ueber dieselbe Routine wie
            % die Flaeche: eine Lage genuegt, weil bei so kleinem Radius keine
            % Luecke zum Schriftzug bleibt.
            \pgfmathsetmacro{\dsa@randjetzt}%
                            {\dsa@titelskala*\dsatitelkonturmass}%
            \dsa@titelform{dsa@tzk.center}{dsatitelkante}{\dsa@randjetzt}%
                          {1}{#4}{#5}%
          \fi
          % 5 der Verlauf, vom Schriftzug maskiert
          \shade[shading=dsatitelverlauf, path fading=#1, fit fading=false]
            (dsa@tzk.south west) rectangle (dsa@tzk.north east);
        \fi
      \else
        \ifnum#2=4\relax
          \pgfmathsetlength{\dsa@titelradius}{\dsatitelkonturmass pt}%
          \node[anchor=center, inner sep=1pt] at (dsa@tzk.center)
            {\dsa@titelschriftgrad{#4}\contourlength{\dsa@titelradius}%
             \contour{black}{\textcolor{white}{#5}}};
        \fi
      \fi
    \end{tikzpicture}};}

% Eine einzelne Zeile in einem Zug, alle drei Stufen hintereinander. Fuer
% den Fall, dass nur eine Zeile zu setzen ist — dann gibt es keine
% Nachbarzeile, die dazwischengreifen koennte. So benutzt es
% beispiel/titelgrafik.tex.
\newcommand{\dsaTitelZeileAn}[4]{%
  \dsa@titelzeileAn{#1}{1}{#2}{#3}{#4}%
  \dsa@titelzeileAn{#1}{2}{#2}{#3}{#4}%
  \dsa@titelzeileAn{#1}{3}{#2}{#3}{#4}%
  \dsa@titelzeileAn{#1}{4}{#2}{#3}{#4}}

% Der Titel wird von der UNTEREN Papierkante aus gesetzt. Damit bleibt die
% Unterkante des Titelblocks fest, und jede weitere Zeile schiebt nach oben —
% bei einem dreizeiligen Titel wandert er also nach oben statt in die
% Rahmen-Illustration hinein.
%
% Die Zeilen schreibt der Autor als Folge von \dsaTitelZeile:
%
%   \dsaUmschlagVorne{bild}{%
%     \dsaTitelZeile{Der falsche}%
%     \dsaTitelZeile{Ganter}}
%
% Eine Zeile kann ihren eigenen Schriftgrad haben, etwa fuer einen
% Untertitel. Das PSD fuehrt Titel und Untertitel getrennt, mit 42,8 pt und
% 27,9 pt:
%
%   \dsaUmschlagVorne{bild}{%
%     \dsaTitelZeile{Der falsche Ganter}%
%     \dsaTitelZeile[27.9]{Akt 1 der Fuchsgrund-Reihe}}
%
% Gezaehlt wird in einem ersten Durchgang, gezeichnet im zweiten — nur so
% weiss die erste Zeile, wie hoch sie sitzen muss.
\newlength{\dsatitelunten}      \setlength{\dsatitelunten}{31.3mm}
\newcommand*{\dsatitelzeilenfaktor}{1.0}
% \dsatitelunten ist der Abstand der Grundlinie der LETZTEN Zeile von der
% unteren Papierkante. Der Abstand zweier Zeilen ist das
% \dsatitelzeilenfaktor-fache des Schriftgrads der unteren — so bekommt eine
% kleinere Zeile auch einen kleineren Vorschub.
%
% Beide Werte stehen im PSD: die Textebene „Abenteuertitel" endet 405 px
% ueber der unteren Beschnittkante des Umschlags (3579 px hoch, 300 ppi,
% also 34,3 mm); abzueglich 3 mm Beschnitt sitzt die Unterkante 31,3 mm
% ueber der Papierkante. Der Zeilenabstand ist der Durchschuss der
% Titelschrift, 51,4 pt = 18,1 mm.
%
% Der Titel sitzt damit unten, wie auf offiziellen Umschlaegen. Wer ihn
% hoeher haben will, setzt \dsatitelunten neu — die Unterkante des
% Titelblocks bleibt fest, weitere Zeilen schieben nach oben.
%
% Zum Zeilenabstand: die Flaeche steht 8,4 pt ueber die Schrift hinaus,
% oben und unten. Beim 1,0fachen des Grads ueberlappen sich die Flaechen
% zweier Zeilen und laufen zu einer zusammen — so wie im PSD, wo Titel und
% Untertitel in einem durchgehenden Block liegen. Wer sie getrennt sehen
% will, erhoeht \dsatitelzeilenfaktor auf etwa 1,25.

% ---- Stellbefehle fuer den Titel ----
%
% In die Praeambel des Dokuments, nach \documentclass:
%
%   \dsaTitelGrad{42.8}         Schriftgrad der Titelzeilen in pt
%   \dsaTitelRand{8.4}          Breite der Flaeche um die Schrift in pt
%   \dsaTitelZeilenfaktor{1.0}  Zeilenabstand als Vielfaches des Grads
%   \dsaTitelUnten{31.3mm}      Grundlinie der letzten Zeile ueber der
%                               unteren Papierkante
%   \dsaTitelTiefer{2.5pt}      Versatz der Flaeche nach unten
%   \dsaTitelKontur{0.24}       Breite der Kontur in pt (1 px bei 300 ppi)
%   \dsaTitelVerlaufAus         schlicht weiss mit Kontur statt Verlauf
%   \dsaTitelFlaecheAus         ohne die Flaeche
%   \dsaTitelRahmenAus          ohne die feine Kontur
%   \dsaTitelSchattenAus        ohne die beiden Schlagschatten
%
% Und die Farben, alle vier einzeln:
%
%   \dsaTitelSchriftfarben{oben}{unten}  Verlauf in der Schrift
%   \dsaTitelKonturfarbe{Farbe}          der helle Rand um die Schrift
%   \dsaTitelFlaechenfarbe{Farbe}        die Flaeche dahinter
%   \dsaTitelSchattenfarbe{Farbe}        beide Schlagschatten
%   \dsaTitelRot                         die drei ersten auf einmal, rot
%
% Und die Masse der Schlagschatten:
%
%   \dsaTitelSchattenWinkel{150}         Lichtwinkel, beide Schatten
%   \dsaTitelSchattenWeg{6.0}            Versatz des Schriftschattens
%   \dsaTitelSchattenWeich{6.8}          Weichzeichnung des Schriftschattens
%
% Eine einzelne Zeile kann ihren Grad selbst mitbringen:
%   \dsaTitelZeile[27.9]{Akt 1 der Fuchsgrund-Reihe}
\newcommand{\dsaTitelGrad}[1]{\renewcommand*{\dsatitelgrad}{#1}}
\newcommand{\dsaTitelRand}[1]{\renewcommand*{\dsatitelrand}{#1}}
\newcommand{\dsaTitelZeilenfaktor}[1]{%
  \renewcommand*{\dsatitelzeilenfaktor}{#1}}
\newcommand{\dsaTitelUnten}[1]{\setlength{\dsatitelunten}{#1}}
\newcommand{\dsaTitelTiefer}[1]{\renewcommand*{\dsatitelflaechetiefer}{#1}}
% Breite der Kontur, als Zahl in pt. Setzt beide Fassungen: die Laenge fuer
% den \contour-Weg und die Zahl fuer den Strich.
\newcommand{\dsaTitelKontur}[1]{\renewcommand*{\dsatitelkonturmass}{#1}}

% ---- Die Farben des Titels ----
%
% Voreinstellung ist der graue Titel des Baukastens. Jedes Argument ist ein
% Farbausdruck von xcolor, also ein mit \definecolor angelegter Name, einer
% der Klasse — oder eine Mischung wie „dsadunkelrot!70!black":
%
%   \definecolor{meinrot}{HTML}{B22526}
%   \dsaTitelSchriftfarben{meinrot}{dsadunkelrot}
%
% In die Praeambel, nicht zwischen zwei Umschlaege: die Schattierung des
% Schriftverlaufs wird beim ersten Gebrauch in ein PDF-Objekt gegossen und
% danach unter ihrem Namen wiederverwendet. Zwei verschieden gefaerbte
% Titel in EINEM Dokument gaebe es damit nicht — ein Fall, den es bei einem
% Umschlag je Heft nicht gibt.
\newcommand{\dsaTitelSchriftfarben}[2]{%
  \colorlet{dsatitelhell}{#1}%
  \colorlet{dsatiteldunkel}{#2}%
  \dsa@titelverlaufneu}
\newcommand{\dsaTitelKonturfarbe}[1]{\colorlet{dsatitelkante}{#1}}
\newcommand{\dsaTitelFlaechenfarbe}[1]{\colorlet{dsatitelflaeche}{#1}}
\newcommand{\dsaTitelSchattenfarbe}[1]{\colorlet{dsatitelschatten}{#1}}

% ---- Die Masse der beiden Schlagschatten ----
%
% Alle in bp zum Bezugsgrad 42,8 pt; sie skalieren mit dem Grad der Zeile.
% Die Voreinstellungen und ihre Messung stehen oben bei den Makros.
%
%   \dsaTitelSchattenWinkel{150}   Lichtwinkel, gilt fuer beide Schatten
%   \dsaTitelSchattenWeg{6.0}      Versatz des Schriftschattens
%   \dsaTitelSchattenWeich{6.8}    Weichzeichnung des Schriftschattens
%
% Wer die Werte des Musterbogens will statt die der gesetzten Hefte:
%   \dsaTitelSchattenWinkel{120}\dsaTitelSchattenWeg{7.44}%
%   \dsaTitelSchattenWeich{4.32}
\newcommand{\dsaTitelSchattenWinkel}[1]{%
  \renewcommand*{\dsatitelschattenwinkel}{#1}}
\newcommand{\dsaTitelSchattenWeg}[1]{%
  \renewcommand*{\dsatitelschriftschattenweg}{#1}}
\newcommand{\dsaTitelSchattenWeich}[1]{%
  \renewcommand*{\dsatitelschriftschattenweich}{#1}}

% Der rote Titel in einem Befehl. Die vier Werte und ihre Messung stehen
% oben bei den \definecolor, die Herleitung in doku/MASSE.md. Der
% Schlagschatten bleibt schwarz: er ist in der Vorlage genauso schwarz wie
% im grauen PSD.
\newcommand{\dsaTitelRot}{%
  \dsaTitelSchriftfarben{dsatitelrothell}{dsatitelrotdunkel}%
  \dsaTitelKonturfarbe{dsatitelrotkante}%
  \dsaTitelFlaechenfarbe{dsatitelrotflaeche}}

\newcounter{dsa@titelzahl}
\newcounter{dsa@titelnr}
\newcommand{\dsaTitelZeile}[2][\dsatitelgrad]{} % je Durchgang neu belegt
\newlength{\dsa@titelhoehe}
\newlength{\dsa@titelrest}
\newlength{\dsa@titelsumme}
\newlength{\dsa@titelvorschub}

% Hilfsroutine fuer die drei Zeichenstufen: rechnet die Hoehe einer Zeile
% aus und gibt sie an \dsa@titelzeileAn weiter. \dsa@titelrest traegt beim
% Eintritt in eine Stufe die Summe aller Vorschuebe; jede Zeile zieht ihren
% eigenen ab, bevor sie sich setzt. Damit sitzt die letzte Zeile auf
% \dsatitelunten und jede weitere darueber.
%
% \dsa@titelzeilesetzen{Stufe}{Grad}{Text}
\newcommand{\dsa@titelzeilesetzen}[3]{%
  \stepcounter{dsa@titelnr}%
  \pgfmathsetlength{\dsa@titelvorschub}{\dsatitelzeilenfaktor*#2}%
  \addtolength{\dsa@titelrest}{-\dsa@titelvorschub}%
  \setlength{\dsa@titelhoehe}{\dsatitelunten}%
  \addtolength{\dsa@titelhoehe}{\dsa@titelrest}%
  % Zum \edef siehe \dsa@titelform: \pgfdeclarefading nimmt den Namen
  % unexpandiert, „path fading" expandiert ihn — ein Zaehlermakro im Namen
  % greift deshalb ins Leere, ohne Fehlermeldung.
  \edef\dsa@titelname{dsatitelzeile\thedsa@titelnr}%
  \expandafter\dsa@titelzeileAn\expandafter{\dsa@titelname}{#1}%
    {[shift={(0pt,\dsa@titelhoehe)}]current page.south}{#2}{#3}}

\newcommand{\dsaUmschlagVorne}[2]{%
  \dsaHintergrundAus
  \thispagestyle{empty}%
  % erster Durchgang: Zeilen zaehlen, je Zeile ihr Fading anlegen und die
  % Gesamthoehe des Titelblocks summieren.
  % \pgfdeclarefading geht nur ausserhalb einer tikzpicture, und jede Zeile
  % braucht ihr eigenes: derselbe Name zweimal, und die zweite Deklaration
  % wird stillschweigend verworfen.
  \setcounter{dsa@titelzahl}{0}%
  \setlength{\dsa@titelrest}{0pt}%
  \renewcommand{\dsaTitelZeile}[2][\dsatitelgrad]{%
    \stepcounter{dsa@titelzahl}%
    \pgfmathsetlength{\dsa@titelvorschub}{\dsatitelzeilenfaktor*##1}%
    \addtolength{\dsa@titelrest}{\dsa@titelvorschub}%
    \edef\dsa@titelname{dsatitelzeile\thedsa@titelzahl}%
    \expandafter\pgfdeclarefading\expandafter{\dsa@titelname}{%
      \tikz\node[inner sep=1pt, text=white]
        {\dsa@titelschriftgrad{##1}##2};}}%
  #2%
  % Die Summe merken: jede der drei Stufen laeuft die Zeilen von vorn
  % durch und braucht sie wieder.
  \setlength{\dsa@titelsumme}{\dsa@titelrest}%
  \begin{tikzpicture}[remember picture, overlay]
    \node[anchor=center, inner sep=0] at (current page.center)
      {\dsaBildDeckend{216mm}{303mm}{#1}};
    \node[anchor=center, inner sep=0] at (current page.center)
      {\includegraphics[width=216mm,height=303mm]{\dsagrafik{umschlag-vorne}}};
    % Stufe 1: alle Schlagschatten der Flaechen, zuunterst
    \setcounter{dsa@titelnr}{0}%
    \setlength{\dsa@titelrest}{\dsa@titelsumme}%
    \renewcommand{\dsaTitelZeile}[2][\dsatitelgrad]{%
      \dsa@titelzeilesetzen{1}{##1}{##2}}%
    #2%
    % Stufe 2: alle Flaechen, ueber allen Flaechenschatten
    \setcounter{dsa@titelnr}{0}%
    \setlength{\dsa@titelrest}{\dsa@titelsumme}%
    \renewcommand{\dsaTitelZeile}[2][\dsatitelgrad]{%
      \dsa@titelzeilesetzen{2}{##1}{##2}}%
    #2%
    % Stufe 3: alle Schriftschatten, auf den Flaechen
    \setcounter{dsa@titelnr}{0}%
    \setlength{\dsa@titelrest}{\dsa@titelsumme}%
    \renewcommand{\dsaTitelZeile}[2][\dsatitelgrad]{%
      \dsa@titelzeilesetzen{3}{##1}{##2}}%
    #2%
    % Stufe 4: alle Lettern mit Kontur und Verlauf, zuoberst
    \setcounter{dsa@titelnr}{0}%
    \setlength{\dsa@titelrest}{\dsa@titelsumme}%
    \renewcommand{\dsaTitelZeile}[2][\dsatitelgrad]{%
      \dsa@titelzeilesetzen{4}{##1}{##2}}%
    #2%
  \end{tikzpicture}%
  \clearpage\dsaHintergrundAn}

% ---- Umschlag hinten ----
%
% Die Rueckseite hat eigene Rahmen, und sie stehen im IDML. Aus dem Spread
% mit BackCover_Umschlag.tif, umgerechnet auf die Papierkante:
%
%   x  12,70 mm, Breite 125,18 mm, Oberkante 48,83 mm   Klappentext
%   x  72,55 mm, Breite  62,59 mm, Oberkante 182,38 mm  eine Zeile
%   x  78,10 mm, Breite  52,91 mm, Oberkante 194,99 mm  Feld unten mittig
%
% Titel und Klappentext stehen im ersten Rahmen. Fuer das Feld unten gibt es
% \dsaRueckenfeld — dort gehoeren die Anforderungen hin.
\newlength{\dsarueckenlinks}  \setlength{\dsarueckenlinks}{12.70mm}
\newlength{\dsarueckenbreite} \setlength{\dsarueckenbreite}{125.18mm}
\newlength{\dsarueckenoben}   \setlength{\dsarueckenoben}{48.83mm}
\newlength{\dsarueckenfeldx}  \setlength{\dsarueckenfeldx}{78.10mm}
\newlength{\dsarueckenfeldb}  \setlength{\dsarueckenfeldb}{52.91mm}
\newlength{\dsarueckenfeldy}  \setlength{\dsarueckenfeldy}{194.99mm}

\newcommand{\dsaRueckenfeld}[1]{%
  \begin{tikzpicture}[remember picture, overlay]
    \node[anchor=north west, inner sep=0, align=left,
          text width=\dsarueckenfeldb]
      at ([shift={(\dsarueckenfeldx,-\dsarueckenfeldy)}]current page.north west)
      {\fontsize{8bp}{9.6bp}\selectfont #1};
  \end{tikzpicture}}

\newcommand{\dsaUmschlagHinten}[3]{%
  \clearpage\dsaHintergrundAus\onecolumn
  \thispagestyle{empty}%
  \begin{tikzpicture}[remember picture, overlay]
    \node[anchor=center, inner sep=0] at (current page.center)
      {\dsaBildDeckend{216mm}{303mm}{#1}};
    \node[anchor=north west, inner sep=0, align=left,
          text width=\dsarueckenbreite]
      at ([shift={(\dsarueckenlinks,-\dsarueckenoben)}]current page.north west)
      {\dsaandalus\fontsize{23.5bp}{28.2bp}\selectfont #2\par
       \vspace{\dsaRaster{1}}%
       \normalfont\fontsize{10bp}{12bp}\selectfont #3\par};
  \end{tikzpicture}%
  \mbox{}%
  \clearpage\dsaHintergrundAn}

% ---- Rueckseite nach dem Rueckseiten-Paket ----
%
% Das Paket bringt eine fertige Rueckseite mit Zierrahmen, Banner und
% kleiner Aventurienkarte, dazu 28 Fassungen mit je einer hervorgehobenen
% Region. werkzeuge/aufbereiten.py legt sie als ruecken-neutral und
% ruecken-<region> ab -- etwa ruecken-mittelreich.
%
% Alle Masse sind an der Rueckseite einer gesetzten Veroeffentlichung
% vermessen. Sie sind Laengen, damit sich jede Zeile einzeln verschieben
% laesst.
\newlength{\dsarueckelinks}   \setlength{\dsarueckelinks}{27.7mm}
\newlength{\dsarueckebreite}  \setlength{\dsarueckebreite}{81.7mm}
\newlength{\dsarueckentitel}  \setlength{\dsarueckentitel}{57.6mm}
\newlength{\dsarueckenautor}  \setlength{\dsarueckenautor}{62.0mm}
\newlength{\dsarueckenstrich} \setlength{\dsarueckenstrich}{67.5mm}
\newlength{\dsarueckestrichbreite}\setlength{\dsarueckestrichbreite}{65mm}
\newlength{\dsarueckentext}   \setlength{\dsarueckentext}{95.5mm}
\newcommand*{\dsarueckentitelgrad}{18}

% Der graue Kasten unten. Im Vorbild sitzt sein Text ab 76,3 mm, der Kasten
% selbst reicht etwas darueber hinaus.
\newlength{\dsarueckekastenx}  \setlength{\dsarueckekastenx}{72.5mm}
\newlength{\dsarueckekasteny}  \setlength{\dsarueckekasteny}{202.0mm}
\newlength{\dsarueckekastenb}  \setlength{\dsarueckekastenb}{63.0mm}
% Am gerenderten Vorbild abgelesen: rund (160, 157, 154).
\definecolor{dsarueckegrau}{HTML}{A09D9A}

% Ein Feld im grauen Kasten: Rubrik fett, Wert dahinter.
\newcommand{\dsaRueckFeld}[2]{{\bfseries #1:} #2\par}
% Die Kopfzeilen des Kastens, fett und zentriert, mit der Linie darunter,
% die das Vorbild zeigt.
\newcommand{\dsaRueckKopf}[1]{%
  {\centering\bfseries\fontsize{12bp}{13.8bp}\selectfont #1\par}%
  \dsaRueckStrich}
% Ein Strich ueber die Kastenbreite.
\newcommand*{\dsaRueckStrich}{%
  \par\nobreak\vspace{2bp}%
  \noindent\rule{\linewidth}{0.4bp}\par
  \vspace{2bp}\nobreak}

% \dsaRueckseite{<Grafik>}{<Titel>}{<Autorzeile>}{<Klappentext>}{<Kasten>}
%
% Die Grafik ist eine der Rueckseiten aus dem Paket, ohne Endung und ohne
% Ordner: „ruecken-mittelreich" oder „ruecken-neutral".
\newcommand{\dsaRueckseite}[5]{%
  \clearpage\dsaHintergrundAus\onecolumn
  \thispagestyle{empty}%
  \begin{tikzpicture}[remember picture, overlay]
    % Randabfallend: die Vorlage ist A4 ohne Anschnitt, hier auf 216 x 303 mm
    % gebracht und dabei beschnitten, damit kein weisser Streifen bleibt.
    \node[anchor=center, inner sep=0] at (current page.center)
      {\dsaBildDeckend{216mm}{303mm}{\dsagrafik{#1}}};
    % Titel und Autorzeile
    \node[anchor=base west, inner sep=0]
      at ([shift={(\dsarueckelinks,-\dsarueckentitel)}]current page.north west)
      {\dsaandalus\fontsize{\dsarueckentitelgrad bp}%
        {\dsarueckentitelgrad bp}\selectfont #2};
    \node[anchor=base west, inner sep=0]
      at ([shift={(\dsarueckelinks,-\dsarueckenautor)}]current page.north west)
      {\fontsize{12bp}{14.4bp}\selectfont #3};
    \node[anchor=north west, inner sep=0]
      at ([shift={(\dsarueckelinks,-\dsarueckenstrich)}]current page.north west)
      {\rule{\dsarueckestrichbreite}{0.6bp}};
    % Klappentext, Blocksatz in der gemessenen Breite
    \node[anchor=north west, inner sep=0, align=justify,
          text width=\dsarueckebreite]
      at ([shift={(\dsarueckelinks,-\dsarueckentext)}]current page.north west)
      % \parskip steht im Heft auf null; der Klappentext braucht seine
      % Absatzabstaende. Im Vorbild sind es 2,83 mm zwischen den Absaetzen.
      {\fontsize{12bp}{15bp}\selectfont
       \setlength{\parskip}{2.83mm}\setlength{\parindent}{0pt}#4\par};
    % Der graue Kasten
    \node[anchor=north west, inner sep=0]
      at ([shift={(\dsarueckekastenx,-\dsarueckekasteny)}]current page.north west)
      {\begin{tcolorbox}[enhanced, nobeforeafter, sharp corners,
          boxrule=0pt, frame hidden,
          width=\dsarueckekastenb, colback=dsarueckegrau,
          left=3.8mm, right=3.8mm, top=4mm, bottom=4mm,
          % „blankest" schaltet die Fuellung ab; sie kommt ueber
          % „interior style" zurueck.
          interior style={fill=dsarueckegrau},
          % 55 mm sind fuer Blocksatz zu schmal: „Komplexitaet
          % (Spieler/Meister)" wurde gesperrt und trotzdem getrennt.
          % Der Kasten ist schmal: die Rubrikspalte und die Rautenskala
          % muessen zusammen unter 55,4 mm bleiben.
          fontupper=\raggedright\fontsize{9bp}{10.4bp}\selectfont
            \setlength{\dsaanforderungrubrik}{36mm}%
            \setlength{\dsaanforderungskala}{15mm}]
        #5
      \end{tcolorbox}};
  \end{tikzpicture}%
  \mbox{}%
  \clearpage\dsaHintergrundAn}

% ---- Impressum ----
%
% Im deutschen Buchhandel heisst diese Seite Impressum; sie sitzt in der
% Titelei, ueblicherweise auf der Titelrueckseite. Im Englischen: copyright
% page. Der Markenhinweis darin ist der Rechtevermerk.
%
% Aufbau nach dem Vorbild einer gesetzten Scriptorium-Veroeffentlichung:
% Ueberschrift IMPRESSUM, darunter je Rubrik der Name der Rubrik und darunter
% der Wert, alles mittig, dann als eigene Zwischenueberschrift „Disclaimer"
% und der Rechtevermerk.
%
% Die Rubriken dort, als Anhalt:
%   Autor · Redaktion · Lektorat · Korrektorat · Kuenstlerische Leitung ·
%   Coverbild · Satz, Layout und Gestaltung · Innenillustrationen und Plaene ·
%   Version
% Dazu am Ende oft eine Danksagung.

% Die Masse stammen aus einer gesetzten Veroeffentlichung, vermessen mit
% pdftotext -bbox-layout, die Schriftgrade aus dem Vergleich der Zeilenbreiten
% mit denselben Zeichenketten in diesen Schriften:
%
%   Ueberschrift IMPRESSUM   Andalus 23,5 pt, Versalien
%                            Grundlinie 37,6 mm unter der Papieroberkante
%   Rubrikname               Gentium Basic fett 14 pt
%   Wert                     Gentium Basic 10 pt
%   Grundlinie Rubrik -> Wert            14,0 pt
%   Grundlinie Wert -> naechste Rubrik   24,0 pt
%   Grundlinie letzter Wert -> Disclaimer 41,4 pt
%
% Die Messung am Vorbild gibt 12,8 und 25,1 pt. Das sind Abstaende zwischen
% den Unterkanten der Zeilenboxen, nicht zwischen den Grundlinien: pdftotext
% kennt nur die Box. Zwischen einer 14-pt- und einer 10-pt-Zeile
% unterscheiden sich die Unterlaengen um 1,1 pt, und mit dieser Korrektur
% werden aus den beiden Messwerten glatte 14,0 und 24,0 pt.
%   Disclaimer-Text          Gentium Basic 10 pt auf 11,6 pt,
%                            Blockbreite 94,5 mm, Absaetze durch eine
%                            Freizeile getrennt
%
% Alles ist auf die Mitte des Papiers zentriert, nicht auf die Mitte des
% Satzspiegels — der liegt bei zweiseitigem Satz 2 mm daneben.
%
% Die Grundlinienabstaende stehen als Durchschuss im jeweiligen \fontsize:
% TeX setzt zwischen zwei Zeilen den Durchschuss der FOLGENDEN Zeile, also
% traegt jede Zeile den Abstand zu ihrer Vorgaengerin.
% Grundlinie und Grad sind an zwei gesetzten Abenteuern gemessen, US25324
% und US25326: beide setzen IMPRESSUM in Andalus 31,73 bp auf einer
% Grundlinie von y 94,00 pt, das sind 33,16 mm unter der Papierkante. 31,73
% ist derselbe Grad wie der Kapiteltitel — 23,5 pt mal der Skalierung von
% 135 Prozent, die die IDML nennt. Vorher standen hier 34,1 mm und 23,5 bp;
% die 37,6 mm der aelteren Messung waren die Unterkante samt Unterlaengen.
\newcommand*{\dsaimpressumkopf}{33.16mm}  % Grundlinie der Ueberschrift
\newcommand*{\dsaimpressumkopfgrad}{\dsakapitelgrad}
\newcommand*{\dsaimpressumstart}{25.1pt}  % bis zur ersten Rubrikgrundlinie
% Der Satzspiegel ist nicht mittig auf dem Papier: innen 20 mm, aussen 24 mm.
% Seine Mitte liegt also 2 mm neben der Papiermitte, auf einer linken Seite
% nach rechts. Das Impressum steht auf Seite 2, mithin links, und wird um
% diesen Betrag zurueckgeschoben.
\newlength{\dsaimpressumversatz}\setlength{\dsaimpressumversatz}{-2mm}
\newcommand*{\dsaimpressumrubrik}{14}     % Grad Rubrikname
\newcommand*{\dsaimpressumwert}{10}       % Grad Wert
\newcommand*{\dsaimpressumabrubrik}{24.0} % Grundlinie Wert -> Rubrik
\newcommand*{\dsaimpressumabwert}{14.0}   % Grundlinie Rubrik -> Wert
\newcommand*{\dsaimpressumabvermerk}{41.4}% Grundlinie Wert -> Disclaimer
\newcommand*{\dsaimpressumzeile}{11.6}    % Durchschuss im Disclaimer
\newlength{\dsaimpressumblock}\setlength{\dsaimpressumblock}{94.5mm}

\newenvironment{dsaImpressumseite}{%
  \clearpage\onecolumn
  % Keine Seitenzahl, kein Kolumnentitel -- und deshalb der Hintergrund
  % ohne Feld dafuer.
  \dsaHintergrundOhneFeld
  % Die Ueberschrift steht als Knoten am Papier, nicht im Fluss: nur so
  % sitzt ihre Grundlinie auf dem gemessenen Mass, unabhaengig davon, was
  % \topskip mit der ersten Zeile macht.
  \begin{tikzpicture}[remember picture, overlay]
    \node[anchor=base, inner sep=0]
      at ([shift={(0pt,-\dsaimpressumkopf)}]current page.north)
      {\dsaandalus\fontsize{\dsaimpressumkopfgrad bp}{\dsaimpressumkopfgrad bp}%
       \selectfont\MakeUppercase{Impressum}};
  \end{tikzpicture}%
  \begingroup
  \setlength{\parindent}{0pt}%
  % Statt \centering: ein fester Anteil verschiebt auf die Papiermitte, der
  % dehnbare zentriert. \centering allein kennt keinen Versatz.
  \setlength{\leftskip}{\dsaimpressumversatz}%
  \addtolength{\leftskip}{0pt plus 1fil}%
  \setlength{\rightskip}{-\dsaimpressumversatz}%
  \addtolength{\rightskip}{0pt plus 1fil}%
  % \parfillskip bleibt 0pt: mit einem fil-Anteil stehen bei einzeiligen
  % Absaetzen rechts zwei dehnbare Anteile gegen einen links, und die Zeile
  % rutscht nach links statt mittig zu stehen.
  \setlength{\parfillskip}{0pt}%
  \vspace*{\dsaimpressumstart}%
}{%
  \par\endgroup\clearpage\twocolumn}

\newcommand{\dsaImpressumsblock}[2]{%
  \par
  {\fontsize{\dsaimpressumrubrik bp}{\dsaimpressumabrubrik bp}\selectfont
   \bfseries #1\par}%
  \nobreak
  % Im Wert bedeutet \\ einen Absatzwechsel, keinen Zeilenumbruch.
  %
  % Zentriert wird hier ueber \leftskip und \rightskip mit je einem
  % fil-Anteil und \parfillskip auf null; so stehen einzeilige Werte mittig.
  % Ein \\ bricht die Zeile aber mit einem \hfil ab -- dann stehen rechts
  % zwei dehnbare Anteile gegen einen links, und die Zeile rutscht nach
  % links. Gemessen lag „Ulisses Spiele (Layout-Baukasten ...)" mit ihrer
  % Mitte bei 91,65 statt 105 mm.
  {\fontsize{\dsaimpressumwert bp}{\dsaimpressumabwert bp}\selectfont
   \let\\\par #2\par}}

% \dsaRechtevermerk{<Jahr>}{<Name oder Firma>}
%
% Der vorgeschriebene Rechte- und Markenhinweis. Er steht hier WOERTLICH —
% nicht umformulieren, nicht kuerzen, die Versalien nicht glaetten. Die beiden
% Argumente ersetzen die Platzhalter [2020] und [dein Name oder der deiner
% Firma] des Originals.
%
% Aeltere Veroeffentlichungen und aeltere Fassungen des Baukastens fuehren
% einen anderen Wortlaut, unter anderem mit einem anderen Rechteinhaber. Der
% hier ist der aktuelle. Wer eine neuere Fassung vom Verlag hat, ersetzt
% diesen Text — es gibt absichtlich nur diesen einen Ort dafuer.
% Der Textblock ist schmaler als der Satzspiegel und mittig: 94,5 mm. Statt
% \centering, das mit eigenen Raendern nicht zusammengeht, tragen \leftskip
% und \rightskip den Rand und je einen dehnbaren Anteil — das ergibt
% zentrierte Zeilen innerhalb eines schmaleren Blocks.
% Eine Freizeile zwischen zwei Absaetzen des Vermerks.
\newcommand*{\dsa@vermerkluft}{\par\vspace{\dsaimpressumzeile pt}}

\newcommand{\dsaRechtevermerk}[2]{%
  \par
  {\fontsize{\dsaimpressumwert bp}{\dsaimpressumabvermerk bp}\selectfont
   \bfseries Disclaimer\par}%
  \nobreak
  \fontsize{\dsaimpressumwert bp}{\dsaimpressumzeile bp}\selectfont
  \setlength{\leftskip}{\dimexpr(\linewidth-\dsaimpressumblock)/2\relax}%
  \setlength{\rightskip}{\leftskip}%
  \addtolength{\leftskip}{\dsaimpressumversatz}%
  \addtolength{\rightskip}{-\dsaimpressumversatz}%
  \addtolength{\leftskip}{0pt plus 1fil}%
  \addtolength{\rightskip}{0pt plus 1fil}%
  % \parfillskip bleibt 0pt: mit einem fil-Anteil stehen bei einzeiligen
  % Absaetzen rechts zwei dehnbare Anteile gegen einen links, und die Zeile
  % rutscht nach links statt mittig zu stehen.
  \setlength{\parfillskip}{0pt}%
  % Kein \parskip: der wuerde auch hinter „Disclaimer" wirken. Die Freizeile
  % steht einzeln zwischen den Absaetzen.
  \setlength{\parskip}{0pt}%
  Dieses Produkt wurde unter Lizenz erstellt. DAS SCHWARZE AUGE, AVENTURIEN,
  DERE, MYRANOR, THARUN, UTHURIA, RIESLAND und THE DARK EYE sind eingetragene
  Marken der Ulisses Spiele GmbH, Waldems.\dsa@vermerkluft
  Ulisses Spiele und sein Logo sind eingetragene Marken der Ulisses Medien und
  Spiele Distribution GmbH.\dsa@vermerkluft
  Dieses Werk enthält Material, das durch Ulisses Spiele und/oder andere
  Autoren urheberrechtlich geschützt ist. Solches Material wird mit Erlaubnis
  im Rahmen der Vereinbarung über Gemeinschaftsinhalte für SCRIPTORIUM
  AVENTURIS verwendet.\dsa@vermerkluft
  Alle anderen Originalmaterialien in diesem Werk sind Copyright #1 von #2 und
  werden im Rahmen der Vereinbarung über Gemeinschaftsinhalte für SCRIPTORIUM
  AVENTURIS veröffentlicht.\par}

% ---- Inhaltsverzeichnis ----
% Die Eintraege setzt die Klasse selbst, statt \l@section aus article zu
% nehmen: dessen Abstaende sind in pt und passen nicht ins Raster, und seine
% Einrueckungen und Nummerierungen braucht ein Abenteuerheft nicht. Eine
% Zeile je Eintrag, Punktfuehrung, Seitenzahl rechts.
%
% Der Durchschuss der Ueberschrift ist zwei Rastereinheiten, nicht das
% 1,2fache des Grades — sonst sitzt schon die erste Zeile daneben.
\renewcommand*{\l@section}[2]{%
  \par\noindent
  \hbox to \linewidth{%
    \strut #1\hspace{0.5em}%
    \leaders\hbox{\hspace{0.4em}.\hspace{0.4em}}\hfill
    \hspace{0.5em}#2}%
  \par}
\renewcommand*{\l@subsection}[2]{%
  \par\noindent
  \hbox to \linewidth{%
    \hspace{6mm}\strut #1\hspace{0.5em}%
    \leaders\hbox{\hspace{0.4em}.\hspace{0.4em}}\hfill
    \hspace{0.5em}#2}%
  \par}

% Die Ueberschrift sitzt auf der ersten Rasterlinie, 84 bp = 29,63 mm unter
% der Papieroberkante — dort, wo im Musterbogen des Baukastens jede
% Seitenueberschrift steht. Als Knoten am Papier, damit sie den Textfluss
% nicht verschiebt: im Fluss wuerde \topskip sie nach unten druecken, weil
% eine Andalus-Zeile in 23,5 bp hoeher ist als der Vorlauf bis zur ersten
% Rasterlinie.
\newlength{\dsainhaltkopf}\setlength{\dsainhaltkopf}{84bp}
\newcommand*{\dsainhaltkopfgrad}{23.5}

\newcommand{\dsaInhalt}{%
  \clearpage\onecolumn
  % Keine Seitenzahl, kein Kolumnentitel -- und deshalb der Hintergrund
  % ohne Feld dafuer.
  \dsaHintergrundOhneFeld
  \dsa@linkerrandsetzen
  \begin{tikzpicture}[remember picture, overlay]
    \node[anchor=base west, inner sep=0]
      at ([shift={(\dsa@linkerrand,-\dsainhaltkopf)}]current page.north west)
      {\dsaandalus\fontsize{\dsainhaltkopfgrad bp}{\dsainhaltkopfgrad bp}%
       \selectfont\MakeUppercase{Inhalt}};
  \end{tikzpicture}%
  % Zwei Rastereinheiten Vorlauf: eine fuer die Zeile der Ueberschrift, eine
  % als Abstand. Die erste Eintragszeile sitzt damit auf der dritten
  % Rasterlinie.
  \dsaRasterluft{2}%
  % Zweispaltig, mit demselben Steg wie der Fliesstext.
  \setlength{\columnsep}{5mm}%
  \begin{multicols}{2}%
    \@starttoc{toc}%
  \end{multicols}%
  \clearpage\twocolumn}

% ---- Seite ohne Seitenzahl ----
%
% Ohne Zahl gehoert auch der Hintergrund ohne Feld dafuer -- sonst bleibt
% die Kartusche in der unteren Aussenecke leer.
\newenvironment{dsaSeiteOhneZahl}{%
  \clearpage\dsaHintergrundOhneFeld
}{\clearpage}

% ---- Ganzseitige Grafik im Grafikbereich ----
\newcommand{\dsaGanzseite}[1]{%
  % Auch hier keine Zahl, also der Hintergrund ohne Feld dafuer.
  \clearpage\dsaHintergrundOhneFeld
  \begin{tikzpicture}[remember picture, overlay]
    \node[anchor=north, inner sep=0]
      at ([shift={(0pt,-\dsagrafikoben)}]current page.north)
      {\dsaBildDeckend{\dsagrafikbreite}{\dsagrafikhoehe}{#1}};
  \end{tikzpicture}%
  \clearpage}

% ---- Querformat, etwa fuer einen Meisterschirm ----
%
% Zwei Befehle, keine Umgebung: \newgeometry darf nicht in einer Gruppe
% stehen, eine \newenvironment-Umgebung bildet aber eine.
%
% \newgeometry allein genuegt nicht. Es nimmt keine Papierformatangaben an —
% „a4paper" und „landscape" werden dort verworfen, und die Seite bleibt
% hochkant, nur mit breiterem Textblock. Gemessen war die Querseite 210 x
% 297 mm wie jede andere.
%
% Die Papiergroesse mitten im Dokument aendert man ueber die Ausgabemasse:
% \pagewidth und \pageheight sind die XeTeX-Register dafuer. \paperwidth und
% \paperheight muessen mit, sonst rechnen geometry und TikZ weiter mit dem
% alten Papier — „current page" waere dann falsch.
\newlength{\dsa@querbreite} \setlength{\dsa@querbreite}{297mm}
\newlength{\dsa@querhoehe}  \setlength{\dsa@querhoehe}{210mm}

\newcommand*{\dsaQuerAnfang}{%
  \clearpage
  \setlength{\paperwidth}{\dsa@querbreite}%
  \setlength{\paperheight}{\dsa@querhoehe}%
  \newgeometry{margin=15mm}%
  % Nach \newgeometry: geometry schreibt beim Aufruf seine gespeicherten
  % Papiermasse in die Ausgaberegister zurueck. Davor gesetzt, waeren sie
  % gleich wieder ueberschrieben, und die Seite bliebe hochkant.
  % dvipdfmx nimmt die Papiergroesse aus einem Special; \pagewidth gibt es
  % in XeTeX nicht.
  \special{papersize=297mm,210mm}%
  % \newgeometry hat \normalsize gezogen; ausdruecklich neu setzen, damit
  % der Durchschuss nicht von der Reihenfolge der Aufrufe abhaengt.
  \normalsize
  % \topskip gilt fuer einen Satzspiegel ab 24 mm. Hier beginnt er bei
  % 15 mm, also neu rechnen: die erste Rasterlinie liegt bei 12,7 mm, die
  % erste unter dem Rand ist die zweite bei 12,7 + 2 * 12 bp = 21,17 mm.
  % Ohne das lagen alle Zeilen der Querseite 1,5 bp unter dem Raster.
  \ifdsa@raster
    \setlength{\topskip}{\dimexpr 12.7mm+2\dsaRastermass-15mm\relax}%
  \fi
  \onecolumn\pagestyle{empty}\dsaHintergrundAus}

\newcommand*{\dsaQuerEnde}{%
  \clearpage
  \setlength{\paperwidth}{\dsa@querhoehe}%
  \setlength{\paperheight}{\dsa@querbreite}%
  \restoregeometry
  \special{papersize=210mm,297mm}%
  \normalsize
  \ifdsa@raster\setlength{\topskip}{\dsa@topskip}\fi
  \pagestyle{fancy}\dsaHintergrundAn\twocolumn}
% \restoregeometry stellt \textheight wieder her, und die Grundlinien sitzen
% danach wieder. Nachgemessen an beispiel.pdf: die Seite nach dem Querformat
% traegt ihre Zeilen auf +0,00 bp. Die Probe ist nur zwei Zeilen lang, aber
% sie greift dort, wo es darauf ankommt — waere \topskip nicht
% zurueckgesetzt, laege schon die erste daneben.

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

% Die Probenzeile: ein farbiger Balken ueber die Spaltenbreite, darin der
% Name der Probe. Gemessen an einer gesetzten Veroeffentlichung, drei
% Vorkommen auf zwei Seiten: der Balken ist 6,985 mm hoch und so breit wie
% die Spalte, der Text steht in Gentium Basic fett auf 11 bp und schwarz,
% seine Grundlinie 4,87 mm unter der Balkenoberkante.
%
% Die Farbe wechselt dort je Probenart und steht im PDF nur als
% Pantone-Name, nicht als Wert. Deshalb ist sie hier ein optionales
% Argument mit dem Pergamentgelb des Baukastens als Voreinstellung:
% \dsaProbe[dsatabellenrot]{Odem Arcanum}.
%
% 6,985 mm sind 19,8 bp und damit kein Vielfaches des Rasters. Der Balken
% behaelt sein Mass; gesetzt wird er wie der gelbe Abschnitt in einer Box
% ohne Hoehe, die zwei Rastereinheiten belegt, damit sein Text auf einer
% Grundlinie sitzt und der Text darunter auch.
\newlength{\dsaprobehoehe}   \setlength{\dsaprobehoehe}{6.985mm}
\newlength{\dsaprobetiefer}  \setlength{\dsaprobetiefer}{6.6bp}
\newcommand*{\dsaprobegrad}{11}

\newcommand{\dsaProbe}[2][dsapergamentgelb]{%
  \par\dsaRasterluft{1}%
  \nobreak\noindent
  \makebox[\linewidth][l]{%
    \raisebox{-\dsaprobetiefer}[0pt][0pt]{%
      \begin{tcolorbox}[
        enhanced, blankest, nobeforeafter, width=\linewidth,
        height=\dsaprobehoehe, valign=center,
        left=1.5mm, right=1.5mm, top=0pt, bottom=0pt,
        colback=#1]
        \dsa@lineskipraster\bfseries
        \fontsize{\dsaprobegrad bp}{\dsaprobegrad bp}\selectfont #2
      \end{tcolorbox}}}%
  \par
  \dsaRasterluft{1}\nobreak}

\newcommand{\dsaZusammenfassung}[5]{%
  \begin{dsaWerteblock}
    \dsaFeld{Stichworte zum Abenteuer}{#1}
    \dsaFeld{Genre}{#2}
    \dsaFeld{Voraussetzungen}{#3}
    \dsaFeld{Ort}{#4}
    \dsaFeld{Zeit}{#5}
  \end{dsaWerteblock}}

% Die Rubriken sind der heutige Stand des Baukastens.
%
% Rubrikspalte und Skalenbreite sind Laengen: im grauen Kasten der
% Rueckseite bleiben nur 55,4 mm, und mit 40 plus 18 mm liefen die Rauten
% hinaus.
\newlength{\dsaanforderungrubrik}\setlength{\dsaanforderungrubrik}{40mm}
\newlength{\dsaanforderungskala} \setlength{\dsaanforderungskala}{18mm}

\newcommand{\dsaAnforderungen}[4]{%
  \par\noindent\textbf{Anforderungen:}\par
  % Zwischen den Spalten liegt sonst zweimal \tabcolsep, also 4,23 mm.
  % Mit 38 mm Rubrik und 15 mm Skala sprengt das die 55,4 mm des grauen
  % Kastens um 10,86 pt. Der Abstand steht deshalb ausdruecklich auf 2 mm.
  \noindent\begin{tabular}{@{}p{\dsaanforderungrubrik}@{\hspace{2mm}}l@{}}
    Kampftalente                  & \dsaRautenRot{#1}{\dsaanforderungskala}\\
    Gesellschaftstalente          & \dsaRautenRot{#2}{\dsaanforderungskala}\\
    Handwerkstalente              & \dsaRautenRot{#3}{\dsaanforderungskala}\\
    \textbf{Lebendige Geschichte} & \dsaRautenGruen{#4}{\dsaanforderungskala}\\
  \end{tabular}\par}

%%% ==================================================================
%%% 20  Freigestellte Grafiken und Textumfluss
%%% ==================================================================
%
% LaTeX setzt im zweispaltigen Satz erst die linke Spalte fertig, dann die
% rechte. Ein automatischer Umfluss ueber die Spaltengrenze ist damit
% ausgeschlossen — in InDesign geht es, weil dort beide Spalten gleichzeitig
% im Blick sind. Deshalb vier Bausteine, von einfach nach aufwendig.

% \dsaBildRaster{<Rastereinheiten>}{<Inhalt>}
%
% Setzt beliebigen Inhalt so, dass er genau so viele Rastereinheiten belegt.
% Der Inhalt bekommt Hoehe und Tiefe null und wird nach unten verschoben; den
% Raum gibt \dsaRasterluft. Eine \parbox mit fester Hoehe taete es nicht:
% ihre Grundlinie liegt bei [t] an der Oberkante und bei [c] in der Mitte,
% und beides verschiebt alles darunter.
%
% Damit ist jedes Bild rastertreu — auch ein Kreisbild oder eine Freiform,
% deren Hoehe man nicht im Voraus kennt:
%
%   \dsaBildRaster{7}{\dsaBildKreis{25mm}{grafiken/portrait}}
\newcommand{\dsaBildRaster}[2]{%
  \par\nobreak
  \noindent\makebox[\linewidth][c]{%
    \raisebox{-\dsaRaster{#1}}[0pt][0pt]{#2}}%
  \par\dsaRasterluft{#1}\nobreak}

\newcommand{\dsaBildSpalte}[2]{%
  \dsaBildRaster{#2}{%
    \dsaBildDeckend{\linewidth}{\dsaRaster{#2}}{#1}}}

\newcommand{\dsaBildBreit}[2]{%
  \begin{figure*}[t]
    \centering
    \dsaBildRaster{#2}{%
      \dsaBildDeckend{\textwidth}{\dsaRaster{#2}}{#1}}%
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
% Beide Befehle bauen die \parshape-Liste selbst auf. \parshape braucht die
% Zeilenzahl und danach genau doppelt so viele Laengen; ist die Liste falsch,
% bricht der Lauf mit unverstaendlicher Meldung ab. Sie ist richtig:
% beispiel.tex setzt \dsaUmfluss{l}{2}{4}{25mm} und \dsaUmflussKontur mit
% acht Werten, und das Dokument baut.

\endinput

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
\IfFileExists{schriften/GenBasR.ttf}
  {\newcommand*{\dsa@schriften}{schriften/}}
  {\IfFileExists{../schriften/GenBasR.ttf}
     {\newcommand*{\dsa@schriften}{../schriften/}}
     {\newcommand*{\dsa@schriften}{schriften/}%
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
\definecolor{dsatabellenlinie}{HTML}{BFBFBF}
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
% Die Nummer der ausgegebenen Seite steht im Haken nicht in \value{page} —
% der LaTeX-Zaehler ist dort noch nicht gesetzt —, sondern in \count0, dem
% Register, das TeX beim Ausschiessen fuehrt. Mit \value{page} war die
% Variante auf jeder Seite 0 und die Lage immer die linke.
\newcommand*{\dsa@bgseite}{\the\count0}
% Die Folge soll 0,0,1,1,2,2,3,3 sein: je zwei Seiten eine Variante,
% beginnend mit der ersten. Deshalb wird (Seite - 1) geteilt — mit der Seite
% selbst waere die Folge 0,1,1,2,2,3,3,0 und die erste Variante kaeme nur
% einmal vor.
\newcommand*{\dsa@bgvariante}{%
  \intcalcMod{\intcalcDiv{\numexpr\dsa@bgseite-1\relax}{2}}{4}}

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
% Die Lage ist im Vorbild nicht spiegelbildlich, und zwar stabil: zwei
% rechte Seiten enden beide 24,29 mm von der Aussenkante, unmittelbar an der
% Zahl; zwei linke beginnen beide 40,35 mm von der Aussenkante, also mit
% 12,8 mm Abstand zu ihr. Das ist uebernommen, nicht geglaettet -- wer es
% anders will, aendert die zwei Laengen.
\newlength{\dsakolumneaussenrechts}
\setlength{\dsakolumneaussenrechts}{24.29mm}
\newlength{\dsakolumneaussenlinks}
\setlength{\dsakolumneaussenlinks}{40.35mm}
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
    \ifx\dsa@kolumnemarke\@empty
      \dsa@abenteuertitel
    \else
      \ifx\dsa@abenteuertitel\@empty
        \leftmark
      \else
        \dsa@abenteuertitel\,--\,\leftmark
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

\newcommand*{\dsa@bannerblock}[1]{%
  \dsa@linkerrandsetzen
  \begin{tikzpicture}[remember picture, overlay]
    \node[anchor=north, inner sep=0]
      at ([shift={(0pt,-\dsabannerversatz)}]current page.north)
      {\includegraphics[width=210.1mm]{\dsagrafik{kapitelbanner}}};
    % anchor=base west: die Grundlinie sitzt auf dem gemessenen Mass, der
    % Anfang der Zeile am inneren Rand. Kein text width und kein align —
    % der Titel ist linksbuendig.
    \node[anchor=base west, inner sep=0]
      at ([shift={(\dsa@linkerrand,-\dsabannertitelunten)}]%
          current page.north west)
      {\dsaandalus\fontsize{23.5bp}{28.2bp}\selectfont
       \MakeUppercase{Kapitel \thedsakapitel: #1}};
  \end{tikzpicture}%
  \dsaRasterluft{10}}
% PRUEFEN: pdfplumber liest fuer die Titelzeilen des Musterbogens 31,7 pt,
% waehrend Absatz- und Zeichenformat 23,5 pt nennen und der Durchschuss von
% 28,2 pt zu 23,5 pt passt. Hier gilt der Formatwert.
% PRUEFEN: Ob der Verlag „Kapitel N:" voranstellt, ist nicht belegt — im
% Musterbogen steht nur der Titel.
% PRUEFEN: Bei zweizeiligen Titeln reichen 10 Rastereinheiten nicht.

% \dsakapitel[<Bild>]{<Titel>}
% Reihenfolge: erst \twocolumn, also neue Seite plus Banner, dann das
% Kapitelbild — sonst landet das Bild auf der Vorseite.
\newcommand{\dsakapitel}[2][]{%
  \stepcounter{dsakapitel}%
  \twocolumn[\dsa@bannerblock{#2}]%
  % In die Marken, damit der Kolumnentitel in der Fusszeile den Namen des
  % Kapitels kennt, auf dessen Seite er steht.
  \markboth{#2}{#2}%
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
  % Zwei Rastereinheiten: eine fuer die Zeile, eine fuer den Abstand danach,
  % den die IDML als SpaceAfter 12 pt nennt. \dsa@lineskipraster haelt den
  % Durchschuss, obwohl die Zeile hoeher ist als er.
  {\centering\dsa@lineskipraster
   \dsaandalus\fontsize{14bp}{24bp}\selectfont #1\par}%
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
% PRUEFEN: beide geschaetzt und fuer alle Kaesten gueltig. Am ersten Abzug
% nachmessen, wie weit der Zierrand der Grafik nach innen reicht.

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

% \dsaPortraitfluss am Anfang des Kasteninhalts: die ersten acht Zeilen
% bleiben schmal, die folgenden laufen auf die volle Kastenbreite. Gilt fuer
% den Absatz, der folgt — bei mehreren Absaetzen also den ersten. Wer den
% Fluss ueber einen ganzen Kasten braucht, setzt den Text als einen Absatz.
%
% Acht Zeilen, und zwar so gerechnet: der Kranz des Ornaments reicht 34,9 mm
% unter die Kastenoberkante, der Text beginnt 6 mm darunter, eine Zeile ist
% 11,4 bp = 4,02 mm hoch. Nicht die Grundlinie der ersten breiten Zeile muss
% unter dem Kranz liegen, sondern ihre Oberkante -- also die Grundlinie
% mindestens eine Versalhoehe von 2,4 mm tiefer, unter 37,3 mm. Mit 6 mm
% Vorlauf sind das acht schmale Zeilen; die neunte beginnt bei 38,2 mm.
%
% Mit sieben Zeilen lief die erste breite Zeile noch in den Kranz. Das war
% an der gerenderten Datei nur zu sehen, wenn man nicht bloss das rechte
% Zeilenende, sondern auch die Hoehe mitmisst.
%
% \parshape verlangt seine Zeilen ausgeschrieben, eine Wiederholung kennt es
% nicht. Wer die Zahl aendert, aendert die Liste — und die 9 davor.
%
% Ohne den Befehl bleibt der Satz durchgehend schmal. Das ist sicher, aber
% enger als noetig.
\newcommand*{\dsaPortraitfluss}{%
  \parshape 9
    0pt \linewidth
    0pt \linewidth
    0pt \linewidth
    0pt \linewidth
    0pt \linewidth
    0pt \linewidth
    0pt \linewidth
    0pt \linewidth
    0pt \dimexpr\linewidth+\dsaportraitfrei-\dsakasteninnen\relax}

\newlength{\dsaportraitinnen}\setlength{\dsaportraitinnen}{5.1mm}
\newlength{\dsaportraitaussen}\setlength{\dsaportraitaussen}{8.4mm}
\tcbset{dsaportraitlage/.style={
  enlarge left by=-\dsaportraitinnen}}

% \dsaKastenNeu{<Umgebung>}{<Breite>}{<Grafikhoehe>}{<Rastereinheiten>}
%              {<Grafik>}{<weitere Schluessel>}
\newlength{\dsa@kastenbreite}

\newcommand{\dsaKastenNeu}[6]{%
  \newtcolorbox{#1}[1][]{%
    dsa@grundkasten,
    % Die Breite der Kastengrafik merken: das Portraitmedaillon braucht sie,
    % weil es an der Grafik haengt und nicht am Rahmen.
    /utils/exec={\setlength{\dsa@kastenbreite}{#2}},
    width=#2, height=\dsaRaster{#4},
    underlay={\node[anchor=north west, inner sep=0] at (frame.north west)
      {\includegraphics[width=#2,height=#3]{\dsagrafik{#5}}};},
    #6, ##1}}

% ---- Pergament ----
\dsaKastenNeu{dsaPergamentKlein} {85.5mm} {50.7mm} {12}{pergament-klein} {dsaueberhang=2.5mm}
\dsaKastenNeu{dsaPergamentMittel}{85.5mm} {99.5mm} {24}{pergament-mittel}{dsaueberhang=2.5mm}
\dsaKastenNeu{dsaPergamentLang}  {85.5mm} {192.4mm}{46}{pergament-lang}  {dsaueberhang=2.5mm}
% Breit und schmal passen nicht in eine Spalte — einspaltig setzen.
% PRUEFEN: Der Baukasten rahmt diese Grafik mit 136,57 x 189,26 mm. Die
% Breite passt zur Produktionsgroesse (136,90 mm), die Hoehe nicht (189,26
% gegen 192,37). Der Rahmen ist also nicht proportional, die Grafik dort
% vermutlich beschnitten. Solange das nicht geklaert ist, gilt die
% Produktionsgroesse.
\dsaKastenNeu{dsaPergamentBreit} {136.9mm}{192.4mm}{46}{pergament-breit} {}
% Produktionsgroesse, hochkant. Der Musterbogen des Baukastens zeigt diese
% Grafik GEDREHT, 186,08 x 47,26 mm — eine Vorfuehrung, keine Vorschrift.
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
% Die Lage der Ringmitte, gemessen an allen drei Portraitkaesten: 17,2 bis
% 18,0 mm von der rechten Bildkante, 18,9 bis 20,2 mm unter der Oberkante.
\newlength{\dsaportraitx}       \setlength{\dsaportraitx}{17.6mm}
\newlength{\dsaportraity}       \setlength{\dsaportraity}{19.4mm}
% Die Groesse steht im IDML: Ornament_Portrait_Wertekasten.psd sitzt in einem
% Rahmen von 35,39 x 34,97 mm bei 300 gegen 300 ppi, also in 100 Prozent. Das
% ist die Aussenkante des Rings; das Bild darin ist kleiner, weil der Ring
% selbst Breite hat.
% PRUEFEN: die beiden Versaetze sind weiter geschaetzt — das IDML sagt, wie
% GROSS das Medaillon ist, nicht wo im Kasten es sitzt.

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

\dsaKastenNeu{dsaWerteKleinPortrait} {94.0mm}{59.2mm} {14}{werte-klein-portrait} {dsaportraitlage,left=7mm,right=\dsaportraitfrei}
\dsaKastenNeu{dsaWerteMittelPortrait}{94.0mm}{104.0mm}{25}{werte-mittel-portrait}{dsaportraitlage,left=7mm,right=\dsaportraitfrei}
\dsaKastenNeu{dsaWerteGrossPortrait} {94.0mm}{199.1mm}{47}{werte-gross-portrait} {dsaportraitlage,left=7mm,right=\dsaportraitfrei}

% ---- Graue Kaesten ----
%
% meister-schmal ist HOCHKANT, 59,9 x 114,2 mm. meister-breit ist mit
% 177,9 mm breiter als die Satzbreite von 166 mm und ragt je Seite 5,95 mm
% hinaus — einspaltig setzen.
% PRUEFEN: Das IDML rahmt Meisterkasten.psd mit 84,60 x 42,25 mm — quer,
% obwohl die Grafik mit 707 x 1349 px hochkant ist. Das passt zu keiner
% Skalierung und deutet auf einen gedrehten Rahmen; Drehungen liest das
% Messwerkzeug nicht aus. Hier gilt die Produktionsgroesse.
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
      % Die Pergamentflaeche wird beschnitten, nicht gestaucht: bei 14
      % Rastereinheiten waeren aus 192,4 mm Grafik 59,3 mm zu machen, ein
      % Faktor von 3,2, und die Textur waere sichtbar gequetscht.
      \node[anchor=north west, inner sep=0] at (frame.north west)
        {\dsaBildDeckend{85.5mm}{\dsaRaster{#2}}{\dsagrafik{pergament-lang}}};
      % 55,80 x 10,37 mm: das Rahmenmass von Absatztrenner_oben.psd im IDML.
      \node[anchor=north, inner sep=0] at (frame.north)
        {\includegraphics[width=55.8mm,height=10.37mm]{\dsagrafik{trenner-oben}}};
      \node[anchor=south, inner sep=0] at (frame.south)
        {\includegraphics[width=55.8mm,height=10.37mm]{\dsagrafik{trenner-unten}}};},
    #1]%
}{\end{tcolorbox}}
% Die Pergamentflaeche wird beschnitten statt gestreckt, und
% pergament-lang hat auch in der Flaeche eine gezeichnete Kante. Sauberer
% waere ein Mittelstreifen zum Kacheln.

%%% ==================================================================
%%% 14  Vorlesetext, Meistermaske, NSC-Kopf
%%% ==================================================================

% Die Zierleiste ist 158,5 x 29,5 mm gross, wird im Baukasten aber auf
% 95,89 x 17,83 mm platziert — 496 gegen 300 ppi, also auf 60 Prozent
% verkleinert. 95,89 mm sind breiter als eine Spalte (80,5 mm); die Leiste
% laeuft dort also ueber den Satz hinaus oder wird schmaler gesetzt. Bis das
% an einem Abzug entschieden ist, bleibt sie auf Spaltenbreite.
% \dsaVorlesetext[<Rastereinheiten>]{<Text>}
%
% Die Zierleiste darueber wird auf Spaltenbreite gesetzt, und ihre Hoehe folgt
% der Proportion der Grafik: 29,5 zu 158,5 ergibt in einer Spalte von 80,5 mm
% rund 42,5 bp. Das ist kein Vielfaches der Rastereinheit, und alles darunter
% sass 4,7 bp neben dem Raster. Die Leiste steht deshalb in einer Box aus
% ganzen Rastereinheiten und darin mittig.
%
% Vier Einheiten passen fuer eine Spalte. Einspaltig braucht die Leiste mehr,
% weil sie breiter und damit hoeher wird — dort acht.
\newcommand{\dsaVorlesetext}[2][4]{%
  \par\dsaRasterluft{1}%
  % Die Grafik hat keine eigene Hoehe (\raisebox mit Null fuer Hoehe und
  % Tiefe) und wird um #1 Rastereinheiten nach unten gesetzt. Den Raum gibt
  % danach \dsaRasterluft, und der ist ein Vielfaches der Rastereinheit.
  \noindent\makebox[\linewidth][c]{%
    \raisebox{-\dsaRaster{#1}}[0pt][0pt]{%
      \includegraphics[width=\linewidth]{\dsagrafik{vorlesetext}}}}%
  \par\dsaRasterluft{#1}%
  \nobreak #2\par
  \dsaRasterluft{1}}
% PRUEFEN: Ob der Vorlesetext kursiv gesetzt wird, sagt der Baukasten nicht —
% hier aufrecht.

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
% Kopfleiste mit Verlauf von „Tabellenrot" nach Weiss, Linien in #BFBFBF.
% Der Baukasten warnt: Objekte mit Farbverlauf gehoeren auf „Multiplizieren".

% Die Kopfleiste ist genau eine Rastereinheit hoch, damit die Tabelle das
% Raster nicht verlaesst. Ihr Text sitzt darin mittig.
%
% Sie darf aber nicht als eigener Absatz stehen: eine Box, die so hoch ist
% wie der Durchschuss, sprengt die Grundlinienregel, TeX nimmt \lineskip,
% und alles darunter lag gemessen 3,3 bp neben dem Raster. Deshalb steht sie
% wie ein Bild in einer Box ohne Hoehe und Tiefe und belegt genau die Zeile,
% in der sie aufgerufen wird.
%
% \dsatabellenkopftiefer schiebt sie so weit nach unten, dass ihr Text auf
% der Grundlinie dieser Zeile sitzt. Der Wert ist an tabtest.pdf gemessen:
% mit 4,6 bp lag der Kopftext 1,2 bp zu tief, mit 3,4 bp sitzt er.
\newlength{\dsatabellenkopftiefer}
\setlength{\dsatabellenkopftiefer}{3.4bp}

\newcommand{\dsaTabellenkopf}[1]{%
  \par\nobreak\noindent
  \makebox[\linewidth][l]{%
    \raisebox{-\dsatabellenkopftiefer}[0pt][0pt]{%
      \begin{tcolorbox}[
        enhanced, blankest, nobeforeafter, width=\linewidth,
        height=\dsaRaster{1}, valign=center,
        left=1.5mm, right=1.5mm, top=0pt, bottom=0pt,
        interior style={left color=dsatabellenrot, right color=white}]
        \bfseries #1
      \end{tcolorbox}}}%
  \par\nobreak}
% PRUEFEN: „blend mode=multiply" braeuchte einen Treiber, der Mischmodi kann.
% Unter XeLaTeX nicht selbstverstaendlich, deshalb weggelassen — auf weissem
% Grund faellt der Unterschied nicht auf.

\newcommand*{\dsaTabellenlinie}{\arrayrulecolor{dsatabellenlinie}}

% Der rastertreue Weg zur Tabelle. \begin{tabular} allein genuegt nicht:
% ohne Positionsargument wird die Tabelle ein \vcenter, dessen Hoehe halbe
% Tabellenhoehe plus Mathe-Achse ist. Die Box ist damit hoeher als eine
% Grundlinie, TeX faellt auf \lineskip zurueck, und der Anfang haengt an der
% Tiefe der letzten Textzeile -- gemessen 0,7 bp neben dem Raster.
%
% \begin{dsaTabelle}{@{}ll@{}} nimmt dasselbe Spaltenformat wie tabular und
% setzt sie in eine Box ohne Hoehe und Tiefe. Mit [t] ist die
% Referenzgrundlinie der Box die erste Zeilengrundlinie; sie sitzt damit
% genau auf der laufenden Grundlinie, die Zeilen darunter halten ihre 12 bp
% von selbst. Den Raum liefert \dsaRasterluft, aufgerundet auf ganze
% Rastereinheiten -- deshalb vertraegt die Umgebung auch Linien und
% mehrzeilige Zellen.
\newsavebox{\dsa@tabelle}
\newenvironment{dsaTabelle}[1]
  {\begin{lrbox}{\dsa@tabelle}\begin{tabular}[t]{#1}}
  {\end{tabular}\end{lrbox}%
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
% luftiger braucht, nimmt ein Vielfaches von 12 bp, nicht irgendeinen Wert.
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

% Masse in pt, aus dem PSD umgerechnet (300 ppi, 1 px = 0,24 pt).
%
% Die Flaeche haelt 35 px = 8,4 pt Abstand zur Schrift, auf allen Seiten
% gleich.
%
% Ihren Schlagschatten — im PSD 21 px Abstand unter 120 Grad, 21 px
% Weichzeichnung, 75 Prozent — gibt es hier nicht. Ohne Weichzeichnung
% nachgebildet blieb davon eine zweite, versetzte Silhouette, und die liest
% sich als Schlagschatten des Schriftzugs statt als Schatten einer Flaeche.
% 8,4 pt sind die 35 px des PSD. Mehr laesst die Flaechen zweier Zeilen
% ineinanderlaufen: bei 42,8 pt Zeilenabstand und rund 31 pt hoher Tinte
% bleiben 11,8 pt Luft zwischen den Zeilen, in denen sich zwei Raender von
% je 13 pt um 14 pt ueberlappen. Damit ist auch die Einschnuerung zwischen
% den Zeilen weg. Wer die Zeilen stattdessen zusammenruecken will, nimmt
% \dsaTitelZeilenfaktor{0.95} und laesst den Rand kleiner.
\newcommand*{\dsatitelrand}{13}           % Abstand der Flaeche zur Schrift
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
%
% Den Schlagschatten des Schriftzugs — im PSD 31 px Abstand, 18 px
% Weichzeichnung, 63 Prozent — gibt es hier nicht. Hart nachgebildet, ohne
% Weichzeichnung und ohne Teildeckung, ueberdeckte er die feine Kontur auf
% zwei Seiten und wirkte selbst wie die Umrandung.

% Der Verlauf laeuft nicht ueber die ganze Zeilenhoehe: Photoshop skaliert ihn
% auf 42 Prozent und versetzt ihn nach unten. Darunter bleibt es durchgehend
% dunkel, darueber durchgehend hell. Nachgebildet als Schattierung mit vier
% Haltepunkten; die 100 bp sind eine Bezugshoehe, \shade skaliert sie auf die
% Hoehe der Zeile.
\pgfdeclareverticalshading{dsatitelverlauf}{100bp}{%
  color(0bp)=(dsatiteldunkel); color(15bp)=(dsatiteldunkel);
  color(78bp)=(dsatitelhell);  color(100bp)=(dsatitelhell)}

% Die beiden Lagen hinter dem Schriftzug einzeln schaltbar: der duenne Rahmen
% (die Kontur des Schriftzugs) und der grosse graue (die Ebene „Rahmen").
\newif\ifdsa@titelrahmen  \dsa@titelrahmentrue
\newif\ifdsa@titelflaeche \dsa@titelflaechetrue
\newcommand*{\dsaTitelRahmenAus}{\dsa@titelrahmenfalse}
\newcommand*{\dsaTitelFlaecheAus}{\dsa@titelflaechefalse}

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
%   1 die graue Flaeche in der Form des Schriftzugs
%   2 der helle Rand: die Kontur des Schriftzugs
%   3 der Verlauf in der Schrift
\newcommand{\dsaTitelZeileAn}[4]{%
  % Alle Masse gelten fuer \dsatitelbezugsgrad und skalieren mit dem Grad
  % dieser Zeile.
  \pgfmathsetmacro{\dsa@titelskala}{#3/\dsatitelbezugsgrad}%
  \pgfmathsetmacro{\dsa@titelrandjetzt}{\dsatitelrand*\dsa@titelskala}%
  % Die Versaetze gehoeren an die Ankerkoordinaten, nicht an einen scope:
  % TikZ-Knoten sind transformationsinvariant, ein scope-shift laesst sie
  % stehen. Erst als Teil der Koordinate wirkt der Versatz.
  \pgfmathsetlength{\dsa@titeltiefer}%
                   {\dsa@titelskala*\dsatitelflaechetiefer}%

  \node[anchor=south, inner sep=0] at (#2){%
    \begin{tikzpicture}
      \node[anchor=center, inner sep=1pt, opacity=0] (dsa@tzk)
        {\dsa@titelschriftgrad{#3}#4};
      \path[use as bounding box]
        (dsa@tzk.south west) rectangle (dsa@tzk.north east);
      \ifdsa@titelverlauf
        \ifdsa@titelflaeche
          % 1 die graue Flaeche, gleichmaessig aufgeblaeht, harte Kante
          \dsa@titelform{[shift={(0pt,-\dsa@titeltiefer)}]dsa@tzk.center}%
                        {dsatitelflaeche}{\dsa@titelrandjetzt}%
                        {\dsatitelflaechenstufen}{#3}{#4}%
        \fi
        \ifdsa@titelrahmen
          % 2 der helle Rand um den Schriftzug, ueber dieselbe Routine wie
          % die Flaeche: eine Lage genuegt, weil bei so kleinem Radius keine
          % Luecke zum Schriftzug bleibt.
          \pgfmathsetmacro{\dsa@randjetzt}%
                          {\dsa@titelskala*\dsatitelkonturmass}%
          \dsa@titelform{dsa@tzk.center}{dsatitelkante}{\dsa@randjetzt}%
                        {1}{#3}{#4}%
        \fi
        % 3 der Verlauf, vom Schriftzug maskiert
        \shade[shading=dsatitelverlauf, path fading=#1, fit fading=false]
          (dsa@tzk.south west) rectangle (dsa@tzk.north east);
      \else
        \pgfmathsetlength{\dsa@titelradius}{\dsatitelkonturmass pt}%
        \node[anchor=center, inner sep=1pt] at (dsa@tzk.center)
          {\dsa@titelschriftgrad{#3}\contourlength{\dsa@titelradius}%
           \contour{black}{\textcolor{white}{#4}}};
      \fi
    \end{tikzpicture}};}

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
% Zum Zeilenabstand: die graue Flaeche steht 8,4 pt ueber die Schrift hinaus,
% oben und unten. Beim 1,0fachen des Grads ueberlappen sich die Flaechen
% zweier Zeilen und laufen zu einer zusammen — so wie im PSD, wo Titel und
% Untertitel in einem durchgehenden Block liegen. Wer sie getrennt sehen
% will, erhoeht \dsatitelzeilenfaktor auf etwa 1,25.

% ---- Stellbefehle fuer den Titel ----
%
% In die Praeambel des Dokuments, nach \documentclass:
%
%   \dsaTitelGrad{42.8}         Schriftgrad der Titelzeilen in pt
%   \dsaTitelRand{8.4}          Breite des grauen Rahmens in pt
%   \dsaTitelZeilenfaktor{1.0}  Zeilenabstand als Vielfaches des Grads
%   \dsaTitelUnten{31.3mm}      Grundlinie der letzten Zeile ueber der
%                               unteren Papierkante
%   \dsaTitelTiefer{2.5pt}      Versatz des Rahmens nach unten
%   \dsaTitelKontur{0.24}       Breite der Kontur in pt (1 px bei 300 ppi)
%   \dsaTitelVerlaufAus         schlicht weiss mit Kontur statt Verlauf
%   \dsaTitelFlaecheAus         ohne grauen Rahmen
%   \dsaTitelRahmenAus          ohne die feine Kontur
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

\newcounter{dsa@titelzahl}
\newcounter{dsa@titelnr}
\newcommand{\dsaTitelZeile}[2][\dsatitelgrad]{} % je Durchgang neu belegt
\newlength{\dsa@titelhoehe}
\newlength{\dsa@titelrest}
\newlength{\dsa@titelvorschub}

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
  \begin{tikzpicture}[remember picture, overlay]
    \node[anchor=center, inner sep=0] at (current page.center)
      {\dsaBildDeckend{216mm}{303mm}{#1}};
    \node[anchor=center, inner sep=0] at (current page.center)
      {\includegraphics[width=216mm,height=303mm]{\dsagrafik{umschlag-vorne}}};
    % zweiter Durchgang: zeichnen, von unten gerechnet
    % zweiter Durchgang: zeichnen. \dsa@titelrest traegt noch die Summe aller
    % Vorschuebe; jede Zeile zieht ihren eigenen ab, bevor sie sich setzt.
    % Damit sitzt die letzte Zeile auf \dsatitelunten und jede weitere
    % darueber.
    \setcounter{dsa@titelnr}{0}%
    \renewcommand{\dsaTitelZeile}[2][\dsatitelgrad]{%
      \stepcounter{dsa@titelnr}%
      \pgfmathsetlength{\dsa@titelvorschub}{\dsatitelzeilenfaktor*##1}%
      \addtolength{\dsa@titelrest}{-\dsa@titelvorschub}%
      \setlength{\dsa@titelhoehe}{\dsatitelunten}%
      \addtolength{\dsa@titelhoehe}{\dsa@titelrest}%
      \edef\dsa@titelname{dsatitelzeile\thedsa@titelnr}%
      \expandafter\dsaTitelZeileAn\expandafter{\dsa@titelname}%
        {[shift={(0pt,\dsa@titelhoehe)}]current page.south}{##1}{##2}}%
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
% 34,1 mm ist die Grundlinie; die 37,6 mm der Messung sind deren Unterkante
% samt Unterlaengen der Andalus, also 3,5 mm tiefer.
\newcommand*{\dsaimpressumkopf}{34.1mm}   % Grundlinie der Ueberschrift
\newcommand*{\dsaimpressumkopfgrad}{23.5}
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
  {\fontsize{\dsaimpressumwert bp}{\dsaimpressumabwert bp}\selectfont #2\par}}

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
  \thispagestyle{empty}%
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
% PRUEFEN: Beide Befehle bauen die \parshape-Liste selbst auf. \parshape
% braucht die Zeilenzahl und danach genau doppelt so viele Laengen; ist die
% Liste falsch, bricht der Lauf mit unverstaendlicher Meldung ab. Mit kleinen
% Werten testen, etwa \dsaUmfluss{l}{2}{4}{25mm}.

\endinput

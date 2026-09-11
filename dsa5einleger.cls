%%% dsa5einleger.cls — Dokumentklasse fuer Einleger eines
%%% Spielleiterschirms im Layout von Das Schwarze Auge 5.
%%%
%%%   \documentclass{dsa5einleger}
%%%
%%% Copyright 2026 Leif Janzik. Apache License 2.0, siehe LICENSE.
%%%
%%% Die Klasse laedt dsa5latex.cls und aendert daran, was ein Einleger
%%% anders macht als ein Abenteuer. Alles Uebrige — Schriften, Farben,
%%% Marken im Text, Aufzaehlungen, Kaesten — kommt von dort und ist dort
%%% dokumentiert. Es gibt fuer jeden Farbwert und jeden Schriftaufruf
%%% weiterhin genau eine Quelle.
%%%
%%% Was anders ist, in einem Satz je Punkt:
%%%
%%%   Papier      DIN A4 quer statt A4 hoch.
%%%   Spalten     vier freie Spalten statt zwei feste; ein Block darf
%%%               ueber mehrere laufen.
%%%   Raster      keins. Der offizielle Einleger hat keins, siehe unten.
%%%   Schrift     9 bp auf 10,8 bp statt 10 bp auf 12 bp.
%%%   Tabellen    Titel mit Quellenmarke, Kopfzeile mit Farbverlauf,
%%%               Zeilenhoehe 14,56 bp statt einer Rastereinheit.
%%%   Hintergrund Pergament quer mit Schuppenleiste oben und unten.
%%%
%%% Woher die Masse kommen: doku/MASSE.md, Abschnitt „Einleger". Sie sind
%%% am offiziellen „Universal Spielleiterschirm Einleger, Auflage 5"
%%% nachgemessen — das ist fuer diese Klasse die vierte Quelle neben den
%%% dreien des Baukastens, und sie ist als solche gekennzeichnet.
%%%
%%% Wie man damit setzt: doku/EINLEGER.md. Dort steht jeder Befehl.
%%%
%%% Zeilen mit  % PRUEFEN:  sind gebaut, aber nicht am Ergebnis nachgemessen.
%%% Der Stand jeder Messung steht in doku/PRUEFPLAN.md.

\NeedsTeXFormat{LaTeX2e}
\ProvidesClass{dsa5einleger}[2026/09/09 v1.0 DSA5 Spielleiterschirm-Einleger]

%%% ==================================================================
%%% 1  Optionen
%%% ==================================================================

% Der eigene Hintergrund, nicht der der Buchseiten. Er wird unten in
% Abschnitt 4 gezeichnet; diese Option schaltet ihn ab, so wie
% „ohnehintergrund" in dsa5latex den der Buchseiten abschaltet.
\newif\ifdsa@ein@ohnehintergrund \dsa@ein@ohnehintergrundfalse
% Die Spaltenkanten mitdrucken. Das Gegenstueck zu „rasterzeigen" der
% Abenteuerklasse: es gibt hier kein Raster zu zeigen, wohl aber die vier
% Spalten, und ob ein Block auf ihnen sitzt, sieht man nur so.
\newif\ifdsa@ein@spaltenzeigen \dsa@ein@spaltenzeigenfalse

\DeclareOption{ohnehintergrund}{\dsa@ein@ohnehintergrundtrue}
\DeclareOption{spaltenzeigen}{\dsa@ein@spaltenzeigentrue}
\DeclareOption{entwurf}{\PassOptionsToClass{entwurf}{dsa5latex}}
\DeclareOption*{\PassOptionsToClass{\CurrentOption}{dsa5latex}}
\ProcessOptions\relax

% „ohneraster" schaltet in dsa5latex den \topskip, den Rastersatz und
% \raggedbottom ab — der Einleger braucht alles drei nicht.
% „ohnehintergrund" meint dort die Buchseiten; die will hier niemand, auch
% wenn dieser Einleger seinen eigenen Hintergrund zeichnet.
\PassOptionsToClass{ohneraster,ohnehintergrund}{dsa5latex}
\LoadClass{dsa5latex}

% tabularx fuer Tabellenspalten, die sich die Restbreite teilen. Die
% Abenteuerklasse kommt ohne aus: dort dehnt \extracolsep{\fill} die
% Abstaende zwischen den Spalten. Im Einleger stehen Tabellen mit sechs
% Spalten Fliesstext nebeneinander — dort muessen die Spalten selbst
% dehnbar sein und ihr Text umbrechen.
\RequirePackage{tabularx}
% environ, weil tabularx sich nicht in eine Umgebung wickeln laesst.
% tabularx liest seinen Rumpf als begrenztes Argument bis zum passenden
% \end — in \newenvironment{dsaEinlegertabelle}{...}{\end{tabularx}} steht
% dieses \end aber nicht im Eingabestrom, sondern hinter
% \end{dsaEinlegertabelle}. Der Lauf endete mit „Runaway argument? ... File
% ended while scanning use of \TX@get@body". \NewEnviron sammelt den Rumpf
% in \BODY, und das \end{tabularx} steht dann als Token dahinter, wo
% tabularx es findet.
\RequirePackage{environ}
% Fuer den Farbverlauf der Kopfzeile, siehe \dsa@ein@band.
\usetikzlibrary{fadings}

%%% ==================================================================
%%% 2  Papier und Satzspiegel
%%% ==================================================================
%
% Der offizielle Einleger ist 276 x 216 mm, also kein Normformat. Diese
% Klasse setzt auf DIN A4 quer, 297 x 210 mm — das ist die ausdrueckliche
% Vorgabe fuer dieses Template und der einzige Punkt, an dem es vom
% Original absichtlich abweicht.
%
% Uebernommen wird stattdessen das Spaltenmodell. Am Original nachgemessen
% (Seiten 4 bis 6, alle Tabellenkanten):
%
%   Seitenrand seitlich   31,181 bp = 11,00 mm
%   Spalten               vier
%   Spaltenbreite         171,0 bp = 60,32 mm
%   Spaltenabstand        12,0 bp =  4,23 mm
%
% Die Probe: 31,181 + 4*171 + 3*12 = 751,18 bp, und genau dort liegt die
% rechte Kante jeder Tabelle der vierten Spalte. Die Spaltenkanten treffen
% auf ein Hundertstel bp: 202,18 / 214,18 / 385,18 / 397,18 / 568,18 /
% 580,18. Kein einziger Block steht daneben.
%
% Auf A4 quer bleiben Rand und Abstand, die Spalten werden breiter:
%   (297 - 22) mm = 779,528 bp, davon 3*12 bp Abstand,
%   (779,528 - 36)/4 = 185,882 bp = 65,57 mm je Spalte.
% Das sind 8,7 Prozent mehr als im Original. Die Alternative waeren fuenf
% Spalten zu 51,6 mm — schmaler als das Original, und in eine Spalte von
% 51,6 mm passt keine Tabelle mit vier Wertespalten mehr.

% Das Papier. Eigene Laengen und nicht \paperwidth: geometry setzt
% \paperwidth erst, wenn es seine Schluessel abgearbeitet hat, und die
% Spaltenbreite wird davor gebraucht. Am gesetzten Ergebnis war der Fehler
% sofort zu sehen — gerechnet wurde mit den 210 mm von A4 hoch, und die vier
% Spalten kamen auf 43,8 statt 65,6 mm heraus.
\newlength{\dsaeinlegerbreite} \setlength{\dsaeinlegerbreite}{297mm}
\newlength{\dsaeinlegerhoehe}  \setlength{\dsaeinlegerhoehe}{210mm}

\newlength{\dsaeinlegerrandseitlich}
\setlength{\dsaeinlegerrandseitlich}{31.181bp}

% Oben und unten. Kein Baukastenmass und keins des Originals: dort steht der
% Text unmittelbar an der Zierleiste, und die ist 37,04 bp hoch. Die Leiste
% dieser Klasse ist 8,5 mm = 24,09 bp hoch (Abschnitt 4), ein Rand von 12 mm
% laesst ihr also 3,9 mm Luft nach innen. Frei gewaehlt und einstellbar.
\newlength{\dsaeinlegerrandoben}
\setlength{\dsaeinlegerrandoben}{12mm}

\newlength{\dsaSpaltenabstand}
\setlength{\dsaSpaltenabstand}{12bp}

% Die Zahl der Spalten. \dsaSpalten{n} in der Praeambel aendert sie und
% rechnet die Breite neu; vier ist die des Originals.
\newcommand*{\dsa@ein@spaltenzahl}{4}
\newlength{\dsaSpaltenbreite}

\newcommand*{\dsa@ein@spaltenrechnen}{%
  \setlength{\dsaSpaltenbreite}{%
    \dimexpr(\dsaeinlegerbreite-2\dsaeinlegerrandseitlich
             -\numexpr\dsa@ein@spaltenzahl-1\relax\dsaSpaltenabstand)
            /\dsa@ein@spaltenzahl\relax}}

\newcommand*{\dsaSpalten}[1]{%
  \renewcommand*{\dsa@ein@spaltenzahl}{#1}%
  \dsa@ein@spaltenrechnen
  \dsa@ein@geometrie}

% Der Satzspiegel. \geometry und nicht \newgeometry: das hier laeuft vor
% \begin{document}, und \newgeometry setzt dabei \normalsize auf die Werte
% der Basisklasse zurueck — in dsa5latex steht der Befund dazu bei
% \renewcommand{\normalsize}.
%
% Einseitig, einspaltig. Ein Einleger hat keinen Bund, also keine innere und
% aeussere Kante; und die Spalten macht diese Klasse selbst, nicht der
% Zweispaltensatz von article, weil ein Block ueber mehrere laufen darf.
\newcommand*{\dsa@ein@geometrie}{%
  \geometry{
    paperwidth=\dsaeinlegerbreite, paperheight=\dsaeinlegerhoehe,
    left=\dsaeinlegerrandseitlich, right=\dsaeinlegerrandseitlich,
    top=\dsaeinlegerrandoben, bottom=\dsaeinlegerrandoben,
    ignorehead, headheight=0pt, headsep=0pt,
    ignorefoot, footskip=0pt}}

\@twocolumnfalse
\@twosidefalse
\dsa@ein@spaltenrechnen
\dsa@ein@geometrie

% Keine Fusszeile und keine Seitenzahl. Ein Einleger wird nicht gebunden und
% nicht durchgeblaettert; die Seitenzahl der Abenteuerklasse sitzt ausserdem
% in einer Kartusche, die es im Querformat nicht gibt.
\pagestyle{empty}

% Der Satz beginnt oben an der ersten Zeile, nicht auf einer Rasterlinie.
% \topskip auf die Hoehe einer Tabellenzeile ueber ihrer Grundlinie: so
% liegt die erste Grundlinie 11,20 bp unter der Oberkante des Satzspiegels,
% genau wie die erste Grundlinie einer Tabelle unter ihrer Kopflinie. Der
% Wert ist \dsa@ein@zellhoehe aus Abschnitt 8, hier ausgeschrieben, weil er
% dort erst nach dem Satzspiegel definiert wird.
\setlength{\topskip}{11.20bp}
\setlength{\parindent}{0pt}
\setlength{\parskip}{0pt}
\raggedbottom

%%% ==================================================================
%%% 3  Schrift
%%% ==================================================================
%
% Am Original nachgemessen ist jeder Fliesstext, jede Tabellenzelle und
% jeder Blocktitel Gentium Basic in 9,0 bp. Die Grundlinien innerhalb einer
% Zelle stehen 10,8 bp auseinander — das ist InDesigns Auto-Durchschuss,
% 120 Prozent des Grades. Die Werte 8,73 bis 9,13 bp, die im PDF neben 9,0
% auftauchen, sind waagerechte Laufweitenanpassung von InDesign, kein
% anderer Grad.
%
% Umdefiniert werden die beiden Makros, nicht \normalsize selbst: dsa5latex
% baut \normalsize aus ihnen, und so bleibt es bei einer Quelle.
\renewcommand*{\dsagrundgrad}{9}
\renewcommand*{\dsagrunddurchschuss}{10.8}
\DeclareMathSizes{9bp}{9bp}{7bp}{5bp}

% Die Quellenmarke traegt im Original Minion Pro in 7,0 bp. Minion Pro
% gehoert nicht zum Baukasten und liegt hier nicht vor; gesetzt wird
% Gentium Basic im selben Grad. Der Unterschied betrifft vier Zeichen je
% Marke und faellt in einer 8,79 bp hohen Flaeche nicht auf.
\newcommand*{\dsamarkengrad}{7}

%%% ==================================================================
%%% 4  Hintergrund
%%% ==================================================================
%
% Pergament ueber das ganze Blatt, oben und unten eine Leiste aus dunklen
% Drachenschuppen mit Goldkante. Genau so macht es das Original: seine
% Leisten sind 1694 x 111 px auf 811 x 53,2 bp, also 150 ppi, und sie liegen
% mit Anschnitt ueber der Papierkante.
%
% Der Baukasten hat keinen Querformat-Hintergrund. Er hat aber die vier
% Buchseiten, und die tragen am Bund dasselbe Schuppenmotiv, bei 300 ppi
% 8,5 mm breit. werkzeuge/einleger.py dreht es um 90 Grad und macht daraus
% die Leiste, aus dem Rest der Seite die Flaeche. Die Leiste ist deshalb
% 8,5 statt 18,8 mm hoch: sie steht in ihrer eigenen Aufloesung, statt auf
% das Mass des Originals hochgerechnet zu werden.
%
%   einleger-flaeche-N   303,0 x 216,0 mm, N = 0, 1, 2
%   einleger-leiste-oben   303,0 x 8,5 mm
%   einleger-leiste-unten
%
% Die 303 x 216 mm sind A4 quer plus 3 mm Anschnitt an allen vier Seiten.

\newlength{\dsaeinlegerleiste}
\setlength{\dsaeinlegerleiste}{8.5mm}

% Welche der drei Flaechen. Wie bei den Buchseiten wechselt sie, damit
% mehrere Blaetter nebeneinander nicht dieselbe Maserung zeigen — hier je
% Blatt, nicht je Doppelseite, weil ein Einleger keine hat.
\newcommand*{\dsa@ein@flaeche}{%
  \intcalcMod{\numexpr\count0-1\relax}{3}}

\AddToShipoutPictureBG{%
  \ifdsa@ein@ohnehintergrund\else
    \begin{tikzpicture}[remember picture, overlay]
      \node[anchor=north west, inner sep=0]
        at ([shift={(-\dsabeschnitt,\dsabeschnitt)}]current page.north west)
        {\includegraphics[width=303mm,height=216mm]%
          {\dsagrafik{einleger-flaeche-\dsa@ein@flaeche}}};
      \dsa@ein@leisten
    \end{tikzpicture}%
  \fi}

% Die Zierleisten allein, ohne Pergament. Sie werden zweimal gebraucht:
% hinter dem Pergament einer Tabellenseite und ueber dem Bild einer
% Stimmungsbildseite (Abschnitt 10). Der Aufruf steht innerhalb einer
% tikzpicture mit remember picture und overlay.
%
% Ob die seitlichen Leisten mitkommen, haengt an \ifdsa@ein@rahmenrundum.
% Der offizielle Einleger macht beides: seine Tabellenseiten haben nur die
% waagerechten Leisten, seine Bildseiten einen umlaufenden Rahmen.
\newif\ifdsa@ein@rahmenrundum \dsa@ein@rahmenrundumfalse
\newcommand*{\dsa@ein@leisten}{%
  \node[anchor=north west, inner sep=0]
    at ([shift={(-\dsabeschnitt,\dsabeschnitt)}]current page.north west)
    {\includegraphics[width=303mm,height=\dsaeinlegerleiste]%
      {\dsagrafik{einleger-leiste-oben}}};
  \node[anchor=south west, inner sep=0]
    at ([shift={(-\dsabeschnitt,-\dsabeschnitt)}]current page.south west)
    {\includegraphics[width=303mm,height=\dsaeinlegerleiste]%
      {\dsagrafik{einleger-leiste-unten}}};
  \ifdsa@ein@rahmenrundum
    \node[anchor=north west, inner sep=0]
      at ([shift={(-\dsabeschnitt,\dsabeschnitt)}]current page.north west)
      {\includegraphics[width=\dsaeinlegerleiste,height=216mm]%
        {\dsagrafik{einleger-leiste-links}}};
    \node[anchor=north east, inner sep=0]
      at ([shift={(\dsabeschnitt,\dsabeschnitt)}]current page.north east)
      {\includegraphics[width=\dsaeinlegerleiste,height=216mm]%
        {\dsagrafik{einleger-leiste-rechts}}};
  \fi}

% Die Spaltenkanten zum Mitdrucken. Anders als beim Raster der
% Abenteuerklasse ist das hier die einzige Pruefung, die es gibt: ohne
% Grundlinienraster sagt nur der Blick auf die Kanten, ob ein Block sitzt.
\ifdsa@ein@spaltenzeigen
  \AddToShipoutPictureFG{%
    \begin{tikzpicture}[remember picture, overlay]
      \foreach \n in {0,...,\numexpr\dsa@ein@spaltenzahl-1\relax}{%
        \draw[dsatuerkis, line width=0.2pt, opacity=0.6]
          ([shift={(\dsaeinlegerrandseitlich
                    +\n\dimexpr\dsaSpaltenbreite+\dsaSpaltenabstand\relax,0pt)}]
            current page.north west) --
          ([shift={(\dsaeinlegerrandseitlich
                    +\n\dimexpr\dsaSpaltenbreite+\dsaSpaltenabstand\relax,0pt)}]
            current page.south west);
        \draw[dsadunkelrot, line width=0.2pt, opacity=0.6]
          ([shift={(\dsaeinlegerrandseitlich+\dsaSpaltenbreite
                    +\n\dimexpr\dsaSpaltenbreite+\dsaSpaltenabstand\relax,0pt)}]
            current page.north west) --
          ([shift={(\dsaeinlegerrandseitlich+\dsaSpaltenbreite
                    +\n\dimexpr\dsaSpaltenbreite+\dsaSpaltenabstand\relax,0pt)}]
            current page.south west);}
      \draw[dsatuerkis, line width=0.2pt, opacity=0.6]
        ([shift={(0pt,-\dsaeinlegerrandoben)}]current page.north west) --
        ([shift={(0pt,-\dsaeinlegerrandoben)}]current page.north east);
      \draw[dsatuerkis, line width=0.2pt, opacity=0.6]
        ([shift={(0pt,\dsaeinlegerrandoben)}]current page.south west) --
        ([shift={(0pt,\dsaeinlegerrandoben)}]current page.south east);
    \end{tikzpicture}}
\fi

%%% ==================================================================
%%% 5  Reihen und Kolumnen
%%% ==================================================================
%
% Der Einleger hat kein durchlaufendes Spaltenmodell wie ein Buch. Seine
% Seiten sind aus Bloecken gebaut, und ein Block ist so breit wie eine,
% zwei, drei oder vier Spalten: die Zustaende-Tabelle auf Seite 4 des
% Originals nimmt die Spalten 2 bis 4, darunter stehen drei einzelne
% nebeneinander.
%
% multicol taugt dafuer nicht. Es kann Text ueber alle Spalten setzen — vor
% oder nach dem Satz, nicht mittendrin — und nichts ueber drei von vier.
% Deshalb dieses Modell:
%
%   \begin{dsaReihe}
%     \dsaKolumne{1}{ ...Spalte 1... }
%     \dsaKolumne{3}{ ...breiter Block ueber Spalte 2 bis 4... }
%   \end{dsaReihe}
%
% Die Kolumnen einer Reihe stehen nebeneinander und oben buendig. Wer eine
% Reihe innerhalb einer Kolumne braucht, verschachtelt: so entsteht die
% Seite, auf der links eine Spalte ueber die volle Hoehe laeuft und rechts
% zwei Reihen uebereinander stehen.
%
% Die Summe der Kolumnenbreiten einer Reihe darf die Spaltenzahl nicht
% ueberschreiten; sonst laeuft die Reihe rechts heraus. Geprueft wird das
% nicht — TeX meldet es selbst als Overfull \hbox.

% Die Breite von n Spalten samt der Abstaende dazwischen.
\newcommand*{\dsaKolumnenbreite}[1]{%
  \dimexpr#1\dsaSpaltenbreite
    +\numexpr#1-1\relax\dsaSpaltenabstand\relax}

% Der Trenner zwischen zwei Kolumnen. Vor der ersten ist er leer, danach
% \hfill — so verteilt sich der Spaltenabstand von selbst, auch wenn die
% Kolumnen zusammen schmaler sind als die Reihe.
\newcommand*{\dsa@ein@trenner}{}

% Innerhalb der Reihe ist \par ausgeschaltet.
%
% Eine Reihe ist eine einzige Zeile aus nebeneinanderstehenden Boxen. Eine
% Leerzeile im Quelltext zwischen zwei \dsaKolumne beendet diese Zeile, und
% die naechste Kolumne beginnt eine neue: gemessen standen von vier Kolumnen
% zwei auf der Seite und zwei darunter, und der Lauf meldete dazu nur „You
% can't use \unskip in vertical mode". Ein Quelltext, der ein Feld je Absatz
% schreibt, ist aber das Naheliegende — deshalb wird \par hier unschaedlich
% gemacht statt verboten.
%
% In den Kolumnen selbst wird \par gebraucht: dort stehen Absaetze, Tabellen
% und Listen. \dsaKolumne holt es innerhalb der Minipage zurueck, und weil
% eine Minipage eine Gruppe ist, gilt die Abschaltung danach wieder. Auch
% ineinandergeschachtelte Reihen gehen damit auf.
\newcommand*{\dsa@ein@par}{}

\newenvironment{dsaReihe}
  {\par\noindent
   \let\dsa@ein@par\par
   \let\par\relax
   \renewcommand*{\dsa@ein@trenner}{}%
   \ignorespaces}
  {\let\par\dsa@ein@par\par}

% \unskip vor dem Trenner: ein Zeilenumbruch im Quelltext zwischen zwei
% \dsaKolumne ist ein Leerzeichen, und das ist dehnbare Glue. Ohne \unskip
% teilt sie sich den Rest der Zeile mit dem \hfill, und die Felder stehen
% um ein paar Punkt neben den Spalten. Gemessen war das 1,7 mm.
\newcommand{\dsaKolumne}[2]{%
  \unskip\dsa@ein@trenner
  \begin{minipage}[t]{\dsaKolumnenbreite{#1}}%
    \let\par\dsa@ein@par
    #2%
  \end{minipage}%
  \renewcommand*{\dsa@ein@trenner}{\hfill}%
  \ignorespaces}

% Luft zwischen zwei Bloecken untereinander. Kein Raster, also auch keine
% Rastereinheit: gezaehlt wird in Textzeilen zu 10,8 bp. Im Original stehen
% zwischen zwei Tabellen einer Spalte zwei bis drei Zeilen, je nachdem, wie
% voll die Spalte wird — eine Setzerentscheidung, kein Mass.
%
% Das innere \dimexpr ist noetig, nicht schmueckend. \dsagrunddurchschuss
% ist die Ziffernfolge 10.8, kein Mass: aus \dimexpr2\dsagrunddurchschuss bp
% wird die Laenge 210.8 bp, weil TeX die 2 und die 10.8 zu einer Zahl
% zusammenliest. Gemessen standen zwischen zwei Tabellen 74,4 statt 7,6 mm.
% Erst \dimexpr#1\dimexpr...bp\relax\relax macht aus der 2 einen Faktor.
\newcommand*{\dsaLuft}[1]{%
  \vspace*{\dimexpr#1\dimexpr\dsagrunddurchschuss bp\relax\relax}}

%%% ==================================================================
%%% 6  Die Quellenmarke
%%% ==================================================================
%
% Das graue Schildchen rechts neben jedem Blocktitel, im Original mit der
% Seitenzahl im Regelwerk: „RW 339". Am Original nachgemessen:
%
%   Flaeche       #9D9D9C, 8,79 bp hoch, Ecken gerundet
%   Text          weiss, Minion Pro 7,0 bp (hier Gentium Basic, Abschnitt 3)
%   Grundlinie    1,85 bp ueber der Unterkante
%   Innenluft     3,8 bp links und rechts
%   Lage          rechtsbuendig an der Spaltenkante
%
% Die Breite ist die des Textes: „RW 339" misst 30,57 bp, „RW 255/309"
% misst 43,09 bp. Beides ergibt sich aus 3,8 + Textbreite + 3,8.
%
% Die Farbe steht im Original ausserdem hinter den Rubrikzeilen der
% Abenteuertabellen nicht — sie ist kein Tonwert von Schwarz, sondern ein
% eigener Grauton, und bekommt deshalb einen eigenen Namen.
\definecolor{dsaeinlegermarke}{HTML}{9D9D9C}

\newlength{\dsa@ein@markenhoehe} \setlength{\dsa@ein@markenhoehe}{8.79bp}
\newlength{\dsa@ein@markentiefe} \setlength{\dsa@ein@markentiefe}{1.85bp}
\newlength{\dsa@ein@markenluft}  \setlength{\dsa@ein@markenluft}{3.8bp}
% Die Rundung ist nicht gemessen, sondern abgelesen: die Marke ist an den
% Ecken sichtbar gebrochen, aber keine Halbkreiskappe.
% PRUEFEN: Rundung am Original nachmessen.
\newlength{\dsa@ein@markenrund}  \setlength{\dsa@ein@markenrund}{1.5bp}

\newsavebox{\dsa@ein@marke}
\newcommand*{\dsaQuelle}[1]{%
  \begingroup
    \fontsize{\dsamarkengrad bp}{\dsamarkengrad bp}\selectfont
    \sbox{\dsa@ein@marke}{\color{white}#1}%
    \begin{tikzpicture}[baseline=0pt]
      \path[fill=dsaeinlegermarke, rounded corners=\dsa@ein@markenrund]
        (0pt,-\dsa@ein@markentiefe)
        rectangle (\dimexpr\wd\dsa@ein@marke+2\dsa@ein@markenluft\relax,
                   \dimexpr\dsa@ein@markenhoehe-\dsa@ein@markentiefe\relax);
      \node[anchor=base west, inner sep=0pt]
        at (\dsa@ein@markenluft,0pt) {\usebox{\dsa@ein@marke}};
    \end{tikzpicture}%
  \endgroup}

%%% ==================================================================
%%% 7  Der Blocktitel
%%% ==================================================================
%
% Ueber jeder Tabelle und jedem Kasten steht ihr Name, fett, ohne Einzug an
% der Spaltenkante, und rechts davon die Quellenmarke. Am Original: Titel
% Gentium Basic Bold 9,0 bp, Grundlinie y=44,01, Marke y=43,91 — beide auf
% derselben Grundlinie, der Unterschied von einem Zehntel bp ist die
% Ausrichtung der Marke an ihrer eigenen Kante.
%
% Anders als die Titelzeile der Abenteuertabelle hat der Blocktitel kein
% Band hinter sich. Das Verlaufsband sitzt im Einleger eine Zeile tiefer,
% hinter der Kopfzeile — siehe Abschnitt 8.
%
%   \dsaBlocktitel{Regeneration}         ohne Marke
%   \dsaBlocktitel[RW 339]{Regeneration} mit
\newcommand{\dsaBlocktitel}[2][]{%
  \par\noindent
  {\bfseries #2}%
  \def\dsa@ein@q{#1}%
  \ifx\dsa@ein@q\@empty\else\hfill\dsaQuelle{#1}\fi
  \par\nobreak}

% Die Ueberschrift ueber mehrere Spalten. Im Original steht sie einmal, auf
% Seite 6 ueber der unteren Haelfte: „Modifikationen bei Zauberspruechen und
% Liturgien sowie Ritualen und Zeremonien", Gentium Basic in 12,72 bp,
% zentriert ueber die volle Blattbreite, nicht fett. Der Grad ist krumm,
% weil InDesign ihn skaliert hat; gesetzt wird er wie gemessen.
\newcommand*{\dsaueberschriftgrad}{12.72}
\newcommand{\dsaUeberschrift}[1]{%
  \par\nobreak
  {\centering
   \fontsize{\dsaueberschriftgrad bp}%
     {\dimexpr 1.2\dimexpr\dsaueberschriftgrad bp\relax\relax}%
   \selectfont #1\par}%
  \nobreak}

%%% ==================================================================
%%% 8  Tabellen
%%% ==================================================================
%
% Die Tabelle des Einlegers, am Original nachgemessen (Tabelle
% „Regeneration", Seite 6, Spalte 1 — dort liegen alle Werte offen):
%
%   Titelgrundlinie      y =  44,01
%   Linie ueber dem Kopf y =  48,05   #646363, 0,245 bp
%   Kopfgrundlinie       y =  59,26
%   Linie unter dem Kopf y =  62,61   #646363
%   erste Wertegrundlinie y = 73,80
%   Linie darunter       y =  87,93   #D0D0D0, 0,245 bp
%
% Daraus das Zeilenmodell:
%
%   Zeilenhoehe einzeilig   14,56 bp
%   je weitere Zeile        10,8 bp   (62,61 -> 87,93 = 25,32 = 14,56+10,76)
%   Grundlinie              11,20 bp unter der Zeilenoberkante
%                            3,36 bp ueber der Zeilenunterkante
%
% Die Probe ueber die ganze Spalte: die acht Zeilen der Tabelle messen
% 25,32 / 46,93 / 36,12 / 46,93 / 25,32 / 25,33 / 46,92 / 46,93 bp. Das sind
% zwei-, vier-, drei-, vier-, zwei-, zwei-, vier- und vierzeilige Zellen,
% jede auf 14,56 + (n-1)*10,8 — die groesste Abweichung ist 0,04 bp.
%
% Die 3,36 bp unten sind der Zelleneinzug des Baukastens, 1,2 mm = 3,4016 bp.
% Der Einleger benutzt also dasselbe Mass wie das Buch, nur oben zusaetzlich
% um die Differenz zwischen Durchschuss und Versalhoehe versetzt.
%
% Zwei Dinge macht diese Klasse anders als die Abenteuerklasse, beide, weil
% es hier kein Grundlinienraster gibt:
%
% 1. Die Zeilenhoehe ist 14,56 bp, nicht eine Rastereinheit. Die Tabelle
%    braucht deshalb keine Box ohne Hoehe und keine \dsaRasterluft — sie ist
%    ein gewoehnlicher Block und darf so hoch sein, wie sie ist.
% 2. Die Kopfzeile traegt den Farbverlauf. Im Buch traegt ihn die Titelzeile
%    und der Spaltenkopf ist grau; im Einleger steht der Titel frei auf dem
%    Pergament, und der Verlauf liegt hinter dem Spaltenkopf.

\newlength{\dsa@ein@zellhoehe} \setlength{\dsa@ein@zellhoehe}{11.20bp}
\newlength{\dsa@ein@zelltiefe} \setlength{\dsa@ein@zelltiefe}{3.36bp}
\newlength{\dsa@ein@zeile}     \setlength{\dsa@ein@zeile}{14.56bp}

% Die Linie unter dem Kopf ist dunkler als im Baukasten. Dort sind es 60
% Prozent Schwarz, am Musterbogen gemessen #878785; am Einleger gemessen
% #646363. Zwei verschiedene Dokumente, zwei verschiedene Werte — hier gilt
% der des Einlegers, weil er das Vorbild ist.
\definecolor{dsaeinlegerkopflinie}{HTML}{646363}

% Die Zeilenlinie ist dieselbe wie im Buch: #D0D0D0. Gemessen ist sie 0,245
% bp stark, das ist die PDF-Rundung von 0,25 pt aus der IDML. Gesetzt wird
% 0,25 bp, wie in der Abenteuerklasse.

% ---- Der Zellstrut ----
%
% \extrarowheight und \arraystretch zusammen geben jeder Tabellenzeile die
% gemessene Hoehe und Tiefe. Bei 9 bp auf 10,8 bp ist \strutbox 7,56 bp hoch
% (0,7 Durchschuss) und 3,24 bp tief (0,3 Durchschuss).
%
% Entscheidend ist, in welcher Reihenfolge array die beiden verrechnet.
% \extrarowheight wird zur Hoehe addiert und das Ergebnis dann mit
% \arraystretch multipliziert:
%
%   Hoehe = \arraystretch * (0,7*Durchschuss + \extrarowheight)
%   Tiefe = \arraystretch *  0,3*Durchschuss
%
% Zuerst stand hier \extrarowheight = 11,20 - 1,037*7,56, also die Zugabe
% nach der Multiplikation gerechnet. Am gesetzten Ergebnis nachgemessen war
% jede Zeile 14,684 statt 14,560 bp hoch — 1,037*(7,56+3,373)+3,36, genau
% der doppelt gestreckte Anteil. Nach acht Zeilen ist das ein Millimeter.
%
% Richtig ist die Umkehrung, und sie geht glatt auf:
%
%   \arraystretch   = 3,36 / 3,24 = 1,037037
%   \extrarowheight = 3,24 bp = \dp\strutbox
%   -> Hoehe = 1,037037 * (7,56 + 3,24) = 11,20 bp
%      Tiefe = 1,037037 *  3,24          =  3,36 bp
%      zusammen                             14,56 bp
%
% Die Zugabe oben ist also genau die Tiefe der Zeile. Das ist kein Zufall:
% 11,20 zu 3,36 ist dasselbe Verhaeltnis wie 10 zu 3, und der Strut hat
% 7 zu 3.
%
% Fuer einzeilige Zellen reicht das. Eine mehrzeilige p-Spalte ist eine
% parbox und hoeher als der Strut; ihre letzte Zeile endet dann mit der
% tatsaechlichen Unterlaenge des Textes, und die ist bei „Regeneration" 0
% und bei „Ausweichen" 2,1 bp. Am gesetzten Ergebnis waren die Linien unter
% mehrzeiligen Zellen dadurch um bis zu 3,4 bp verschoben, je nach Wort.
% Deshalb bekommt jede Absatzspalte eine Tiefenstuetze ans Zellenende.
%
% Die Stuetze selbst steht in dsa5latex, an L{}, und ist dort mit
% \dsazellstuetze = 0 pt wirkungslos. Hier bekommt sie ihr Mass, und beide
% Klassen teilen sich denselben Spaltentyp: L{<breite>} ist in beiden
% p{<breite>} mit Flattersatz.
%
% Flattersatz, weil Blocksatz in einer Spalte von 30 mm die Wortabstaende
% aufzieht; in den Zellen des Originals ist durchweg Flattersatz gesetzt.
\setlength{\dsazellstuetze}{\dsa@ein@zelltiefe}

% X teilt sich die Restbreite. tabularx baut jede X-Spalte aus
% \tabularxcolumn; die Umdefinition ist der vom Paket vorgesehene Weg und
% gibt allen X-Spalten dasselbe wie L{} — Flattersatz und Stuetze.
\renewcommand{\tabularxcolumn}[1]{%
  >{\raggedright\arraybackslash}p{#1}<{\dsa@zellstuetze}}

% ---- Das Band hinter der Kopfzeile ----
%
% Gezeichnet wird es von \dsa@tabellenband aus dsa5latex — dasselbe
% Rechteck, dieselben zwei Linien, dieselbe Breite aus \dsa@tabellenbreite.
% Hier werden nur seine drei Freiheiten anders belegt: die Hoehe, die
% Fuellung und die Linienfarbe.
%
% Die Hoehe. dsa5latex rechnet das Band eine Rastereinheit hoch; hier ist
% eine Zeile 14,56 bp, und eine Kopfzeile darf mehrzeilig sein. Das Band
% haengt deshalb an \dsa@ein@bandzeilen, das \dsaKopfzeile setzt. Wie in der
% Abenteuerklasse darf es keine eigene Bauhoehe haben, sonst waere es eine
% Box in der Zeile und schoebe sie auseinander.
%
% Die Zeilenzahl muss die Klasse wissen und kann sie nicht ausrechnen: das
% Band wird gezeichnet, wenn die Zeile beginnt, und wie hoch sie wird, steht
% erst fest, wenn sie zu Ende gesetzt ist. Am Original hat die Kopfzeile
% „Modifikator-Maximum / Fertigkeitswert-Minimum" zwei Zeilen und ein Band
% von 25,36 bp — genau 14,56 + 10,8. Deshalb \dsaKopfzeile[2].
\newcommand*{\dsa@ein@bandzeilen}{1}
\renewcommand*{\dsa@bandmasse}{%
  \setlength{\dsa@bandoben}{\dsa@ein@zellhoehe}%
  \setlength{\dsa@bandunten}{%
    \dimexpr\dsa@ein@zelltiefe
      +\numexpr\dsa@ein@bandzeilen-1\relax
       \dimexpr\dsagrunddurchschuss bp\relax\relax}}

% Die Fuellung. Sie ist Tabellenrot, das nach durchsichtig ausblendet, nicht
% ein Verlauf nach Weiss wie im Buch. Im Original ist es ein Verlauf auf
% „Multiplizieren" ueber dem Pergament: gemessen ist die Flaeche links
% #B47D62, und Tabellenrot #C1907B multipliziert mit dem Pergament #F8F1E9
% ergibt #BB8872 — dieselbe Farbe bis auf die Rundung des Farbprofils. Nach
% Weiss verlaufen wuerde einen hellen Streifen auf das Pergament legen.
%
% Der Mischmodus kommt trotzdem, und er kommt aus dsa5latex: \dsa@tabellenband
% zeichnet seit dem Nachweis am Musterbogen alles unter „blend mode=multiply".
% Beides zusammen ist kein doppelter Effekt, sondern derselbe. Multiplizieren
% ist in der Quellfarbe linear, deshalb gilt
%
%   lerp(Grund, Rot*Grund, a) = Grund * lerp(Weiss, Rot, a)
%
% — links deckendes Rot mal Pergament, rechts unveraendertes Pergament, und
% dazwischen genau der Verlauf, den das Buch mit „shade nach Weiss" plus
% Multiplizieren erzeugt. Die beiden Klassen setzen also dieselbe Flaeche,
% nur anders geschrieben. Nachgemessen am linken Bandende: (191,141,117)
% gegen die Rechnung Tabellenrot mal Pergament (189,139,117).
%
% Sie steht unmittelbar im Aufruf unten und nicht in einem Makro. TikZ liest
% das Argument als Schluesselliste; ein Makro darin kommt bei pgfkeys als
% ein einziger Schluessel an, und der Lauf endete mit „I do not know the key
% '/tikz/fill=dsatabellenrot, path fading=east'".

% \dsaKopfzeile steht ganz am Anfang der Kopfzeile, vor der ersten Zelle:
%
%   \dsaKopfzeile Situation & Regeneration \\
%   \dsaKopfzeile[2] Modifikator-Maximum & Fertigkeitswert-Minimum \\
%
% Das Argument ist die Zahl der Textzeilen, die die Kopfzeile hoch wird.
% Ohne es ist das Band eine Zeile hoch, und eine umbrechende Kopfzeile
% haengt mit ihrer zweiten Zeile unter dem Band — im Abzug sofort zu sehen.
%
% Der Text der Kopfzeile ist fett und im selben Grad wie der Rest — anders
% als im Buch, wo der Spaltenkopf 9,5 bp misst. Das Fett muss in jede Zelle;
% warum eine Schriftart nicht ueber die Zellengrenze reicht, steht in
% dsa5latex bei \dsaRubrikschrift.
\newcommand*{\dsaKopfschrift}{\bfseries}
\newcommand{\dsaKopfzeile}[1][1]{%
  \renewcommand*{\dsa@ein@bandzeilen}{#1}%
  \dsa@tabellenband{\dsatabelleninnen}%
    {fill=dsatabellenrot, path fading=east}{dsaeinlegerkopflinie}%
  \dsaKopfschrift\ignorespaces}

% Die Linie unter jeder Wertezeile ist dieselbe wie im Buch und kommt von
% dort: \dsa@tabellenlinienan aus dsa5latex, Abschnitt 17. Sie zeichnet
% \hrule in 0,25 bp und nimmt die Bauhoehe mit einem \vskip wieder weg.

% ---- Die Tabelle ----
%
%   \begin{dsaEinlegertabelle}{Regeneration}{RW 339}{XL{22mm}}
%     \dsaKopfzeile Situation & \dsaKopfschrift Regeneration \\
%     Grundregeneration für 6 Stunden Schlaf & 1W6 LeP/AsP/KaP \\
%   \end{dsaEinlegertabelle}
%
%   #1  Titel, leer lassen fuer eine Tabelle ohne Titelzeile
%   #2  Quellenmarke, leer lassen fuer keine
%   #3  Spaltenformat wie bei tabularx: X, L{<breite>}, l, r, c
%
% Drei Pflichtargumente und keins davon optional, obwohl zwei leer bleiben
% duerfen. \NewEnviron vertraegt kein optionales Argument: laesst man es
% weg, rutschen die uebrigen um eins, und die Spaltenvorschrift kommt leer
% an. Die Tabelle hat dann eine Spalte statt drei, und der Lauf meldet je
% Zeile und Durchlauf „Extra alignment tab has been changed to \cr" — bei
% einer dreizeiligen Tabelle sechsmal, weil tabularx zweimal setzt. Mit
% Marke geschrieben faellt das nie auf; ohne bricht jede Tabelle.
%
% Die Tabelle ist immer so breit wie die Kolumne, in der sie steht. Die
% Linien laufen von Kante zu Kante, wie im Original von Spaltenkante zu
% Spaltenkante. Die Breite steht in \dsa@tabellenbreite, derselben Laenge,
% aus der auch das Buch sein Band nimmt: \linewidth ist in einer p-Spalte
% die Zellenbreite, nicht die der Tabelle, und das Band waere dort nur so
% breit wie seine erste Zelle.
%
% Das \par am Anfang ist nicht schmueckend. Eine Tabelle ist ein Block und
% muss im vertikalen Modus beginnen. Ohne Titel faellt der \par von
% \dsaBlocktitel weg; die Tabelle stand dann in der laufenden Zeile, und der
% Lauf endete mit „Extra alignment tab has been changed to \cr", einmal je
% Zelle ab der zweiten.
\NewEnviron{dsaEinlegertabelle}[3]{%
  \setlength{\dsa@tabellenbreite}{\linewidth}%
  \def\dsa@ein@t{#1}%
  \ifx\dsa@ein@t\@empty\else\dsaBlocktitel[#2]{#1}\fi
  \setlength{\tabcolsep}{\dsatabelleninnen}%
  \setlength{\arrayrulewidth}{\dsatabellenstrich}%
  \setlength{\extrarowheight}{\dp\strutbox}%
  \renewcommand*{\arraystretch}{1.037037}%
  \arrayrulecolor{dsatabellenlinie}%
  \noindent
  \begin{tabularx}{\linewidth}%
    {@{\hskip\dsatabelleninnen}#3@{\hskip\dsatabelleninnen}}%
    \dsa@tabellenlinienan
    \BODY
  \end{tabularx}%
  % \everycr ist global gesetzt und muss global zurueck.
  \global\everycr{}%
  \par}

% Eine Rubrikzeile mitten in der Tabelle: dieselbe Flaeche wie die
% Kopfzeile, fuer eine Tabelle mit mehreren Abschnitten. Das Original hat
% sie auf Seite 6 in „Modifikatoren fuer die Zeremonieprobe" — dort teilen
% „Ort*", „Zeit*" und „Sonstiges" eine Tabelle in drei Teile, jeder mit
% eigener Kopfzeile. Sie ist bis auf den Namen \dsaKopfzeile; der zweite
% Name steht da, weil im Quelltext einer langen Tabelle sofort zu sehen sein
% soll, welche Zeile den Kopf bildet und welche einen Abschnitt beginnt.
\newcommand{\dsaZwischenzeile}[1][1]{\dsaKopfzeile[#1]}

%%% ==================================================================
%%% 9  Anmerkung unter einer Tabelle
%%% ==================================================================
%
% Die Fussnote am Fuss eines Blocks: „*Nur einer der Modifikatoren kann
% gelten", „*Alle beteiligten Eigenschaften mindestens 13". Am Original
% Gentium Basic 9,0 bp, ohne Einzug an der Spaltenkante, eine Zeile unter
% der letzten Tabellenlinie (Seite 6: letzte Linie y=376,1, Anmerkung
% y=401,87 — das sind 25,8 bp, also zwei Zeilen zu 10,8 plus die 3,36 der
% Zellentiefe und die 11,2 der neuen).
\newcommand{\dsaAnmerkung}[1]{%
  \par\nobreak
  \vspace*{\dimexpr\dsagrunddurchschuss bp-\dsa@ein@zelltiefe\relax}%
  \noindent #1\par}

%%% ==================================================================
%%% 10  Die Stimmungsbildseite
%%% ==================================================================
%
% Eine Seite, auf der nur ein Bild steht, randfuellend. Die ersten drei
% Seiten des offiziellen Einlegers sind so gebaut: je ein einziges Bild von
% 1635 x 1281 px, platziert von -1,08/-1,07 bis 783,54/613,45 bp, also mit
% ueberall 1 bp Ueberstand ueber die Papierkante.
%
% Der Rahmen liegt oben und unten, nicht rundum — genau wie auf den
% Tabellenseiten. Das ist am Original nachgemessen: an beiden senkrechten
% Raendern der Seiten 1 bis 3 steht Bildinhalt bis zur Papierkante, keine
% Leiste. Hier stand zuerst ein umlaufender Rahmen, weil die Raender im
% verkleinerten Abzug dunkel aussahen; das war der dunkle Bildinhalt, nicht
% eine Leiste. Ausgeschnitten und angesehen ist links wie rechts Wiese und
% Wald.
%
% Wer den umlaufenden Rahmen doch will, schaltet ihn mit \dsaRahmenRundum
% ein. Er gilt dann fuer alle folgenden Seiten, auch die mit Tabellen.
%
%   \dsaStimmungsbild{grafiken/szene}    Bild, Leisten oben und unten
%   \dsaStimmungsbild*{grafiken/szene}   Bild ohne Leisten, sie stecken drin
%   \dsaRahmenRundum                     ab hier auch die seitlichen
%   \dsaRahmenWaagerecht                 zurueck zur Vorgabe
%
% Das Bild wird deckend zugeschnitten, nicht gestreckt: \dsaBildDeckend aus
% dsa5latex skaliert an der Kante, an der es zu klein ist, und beschneidet
% die andere mittig. Zugeschnitten wird auf 303 x 216 mm, also A4 quer plus
% 3 mm Anschnitt an allen vier Seiten — dieselbe Flaeche wie beim
% Pergamenthintergrund.
%
% Die Seite bringt ihre eigene Seitenkulisse mit und schaltet die des
% Dokuments ab. Sonst laege das Pergament unter dem Bild, waere 8 MB gross
% und nirgends zu sehen.

\newcommand*{\dsa@ein@bildbreite}{303mm}
\newcommand*{\dsa@ein@bildhoehe}{216mm}

\newcommand{\dsaStimmungsbild}{%
  \@ifstar\dsa@ein@bildseiteohne\dsa@ein@bildseitemit}

\newcommand{\dsa@ein@bildseitemit}[1]{\dsa@ein@bildseite{#1}{\dsa@ein@leisten}}
\newcommand{\dsa@ein@bildseiteohne}[1]{\dsa@ein@bildseite{#1}{}}

% Die beiden Schalter werden global umgelegt und danach auf ihren alten
% Wert zurueckgestellt, nicht auf „falsch". Eine Gruppe taugt dafuer nicht:
% die Seite wird erst beim Ausschiessen zusammengesetzt, und das geschieht
% ausserhalb jeder Gruppe, die das Dokument aufmacht.
\newcommand*{\dsa@ein@hgmerk}{}
%
% #1 Grafik, #2 was ueber das Bild kommt
\newcommand{\dsa@ein@bildseite}[2]{%
  \clearpage
  % Kein Pergament unter dem Bild: es waere 8 MB gross und nirgends zu
  % sehen. Der alte Zustand wird gemerkt, damit eine Bildseite in einem
  % Dokument mit ohnehintergrund nichts wieder anschaltet.
  \ifdsa@ein@ohnehintergrund
    \gdef\dsa@ein@hgmerk{\global\dsa@ein@ohnehintergrundtrue}%
  \else
    \gdef\dsa@ein@hgmerk{\global\dsa@ein@ohnehintergrundfalse}%
  \fi
  \global\dsa@ein@ohnehintergrundtrue
  % Der Rahmen bleibt, wie der Autor ihn eingestellt hat. Vorgabe sind die
  % zwei waagerechten Leisten, wie im Original.
  \AddToShipoutPictureBG*{%
    \begin{tikzpicture}[remember picture, overlay]
      \node[anchor=center, inner sep=0] at (current page.center)
        {\dsaBildDeckend{\dsa@ein@bildbreite}{\dsa@ein@bildhoehe}{#1}};
      #2%
    \end{tikzpicture}}%
  % Eine leere Seite mit Zwangsumbruch: der Inhalt steht vollstaendig im
  % Hintergrund. \null und nicht \mbox{}, damit die Seite auch dann
  % ausgegeben wird, wenn nichts weiter folgt.
  \thispagestyle{empty}%
  \null
  \clearpage
  \dsa@ein@hgmerk}

% Die seitlichen Leisten an- und abschalten. Sie gelten ab dem Aufruf fuer
% jede folgende Seite, Tabellenseiten eingeschlossen — der Rahmen ist eine
% Eigenschaft des Blattes, nicht eines einzelnen Elements.
\newcommand*{\dsaRahmenRundum}{\global\dsa@ein@rahmenrundumtrue}
\newcommand*{\dsaRahmenWaagerecht}{\global\dsa@ein@rahmenrundumfalse}

%%% ==================================================================
%%% 11  Der Pergamentkasten
%%% ==================================================================
%
% Ein Block auf Pergament statt auf blankem Grund, mit dem gezackten Rand
% der Baukastengrafik. Der offizielle Einleger hat zwei davon: „Einsatz von
% Schips" auf Seite 4 und „Modifikationen im Ueberblick" auf Seite 6. Beide
% am Original nachgemessen:
%
%                              Seite 4              Seite 6
%   Kasten                     177,72 x 182,16 bp   349,25 x 103,86 bp
%                              62,7 x 64,3 mm       123,2 x 36,6 mm
%   Spalten darunter           1 (171 bp)           2 (354 bp)
%   Ueberhang je Seite         3,36 bp              -2,4 bp (eingerueckt)
%   Textkante vom Rand         11,89 bp = 4,19 mm   10,01 bp = 3,53 mm
%   Rest rechts                 9,34 bp             11,11 bp
%   Titelgrundlinie unter OK   17,75 bp             21,06 bp
%   letzte Grundlinie ueber UK 13,21 bp             16,37 bp
%   Schrift                    Gentium Basic 9,0 bp, wie der Fliesstext
%
% Zwei Dinge fallen daran auf, und beide bestimmen die Umsetzung:
%
% 1. Der eine Kasten steht ueber seiner Spalte, der andere darin. Der
%    Setzer hat frei platziert; ein Sollmass gibt es nicht. Die Klasse nimmt
%    den Ueberhang von Seite 4, 3,4 bp — dieselben 1,2 mm wie der
%    Zelleneinzug der Tabellen. Ueber \dsapergamentueberhang einstellbar.
% 2. Innen sieht der Kasten aus wie eine Spalte: derselbe Grad, derselbe
%    Blocktitel mit Quellenmarke, dieselben Aufzaehlungen. Er ist kein
%    eigener Satzraum wie der Kasten im Buch (der hat 9,5 bp auf 11,4 bp),
%    sondern ein Stueck Einleger auf anderem Grund.
%
% Der Rahmen kommt von dsa@grundkasten aus dsa5latex, die Flaeche von
% \dsaBildDeckend — beschnitten statt gestaucht, wie in dsaKastenFrei. Ein
% eigener Kasten und nicht dsaPergamentKlein: die fertigen Kaesten der
% Abenteuerklasse sind 85,5 mm breit und rechnen ihre Hoehe in
% Rastereinheiten. Beides gibt es hier nicht.
%
%   \begin{dsaPergament}{1}{15}
%     \dsaBlocktitel[RW 29]{Einsatz von Schips}
%     \begin{dsaliste} \item ... \end{dsaliste}
%   \end{dsaPergament}
%
%   #1  Breite in Spalten
%   #2  Hoehe in Textzeilen zu 10,8 bp

\newlength{\dsapergamentueberhang}
\setlength{\dsapergamentueberhang}{3.4bp}
% Gemessen 11,89 und 10,01 bp; dazwischen. Der Zierrand der Grafik ist an
% dieser Stelle etwa 3 mm breit, der Text steht also knapp daneben.
\newlength{\dsapergamentinnen}
\setlength{\dsapergamentinnen}{3.8mm}
% Oben bis zur Oberkante der ersten Textzeile, nicht bis zu ihrer
% Grundlinie: 17,75 bp minus der Versalhoehe von 9 bp Gentium Basic.
% Am gesetzten Ergebnis nachgemessen liegt die Titelgrundlinie damit 18,07
% bp unter der Kastenoberkante, das Original hat 17,75 — 0,32 bp daneben,
% ein Zehntel Millimeter. Die Textkante links steht 10,57 bp vom Rand und
% damit zwischen den 11,89 und 10,01 bp der beiden Originalkaesten.
\newlength{\dsapergamentoben}
\setlength{\dsapergamentoben}{4mm}
\newlength{\dsapergamentunten}
\setlength{\dsapergamentunten}{3.8mm}

\newlength{\dsa@ein@pbreite}
\newlength{\dsa@ein@phoehe}

\newenvironment{dsaPergament}[2]{%
  \setlength{\dsa@ein@pbreite}{%
    \dimexpr\dsaKolumnenbreite{#1}+2\dsapergamentueberhang\relax}%
  \setlength{\dsa@ein@phoehe}{%
    \dimexpr#2\dimexpr\dsagrunddurchschuss bp\relax\relax}%
  \begin{tcolorbox}[
    dsa@grundkasten,
    width=\dsa@ein@pbreite, height=\dsa@ein@phoehe,
    left=\dsapergamentinnen, right=\dsapergamentinnen,
    top=\dsapergamentoben,   bottom=\dsapergamentunten,
    % Der Kasten haengt links um den Ueberhang aus der Spalte heraus.
    % dsaueberhang verschiebt ihn, ohne ihn breiter zu machen — warum, steht
    % in dsa5latex bei \tcbset{dsaueberhang}.
    dsaueberhang=\dsapergamentueberhang,
    % Die Schrift des Einlegers, nicht die des Buchkastens.
    fontupper=\fontsize{\dsagrundgrad bp}{\dsagrunddurchschuss bp}\selectfont,
    underlay={\node[anchor=north west, inner sep=0] at (frame.north west)
      {\dsaBildDeckend{\dsa@ein@pbreite}{\dsa@ein@phoehe}%
        {\dsagrafik{pergament-lang}}};}]%
}{\end{tcolorbox}}

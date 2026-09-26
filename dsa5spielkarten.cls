%%% dsa5spielkarten.cls — Dokumentklasse fuer Spielkarten im Layout von
%%% Das Schwarze Auge 5, nach den Massen des offiziellen
%%% „Scriptorium Aventuris – Spielkarten"-Baukastens von Ulisses Spiele.
%%%
%%%   \documentclass{dsa5spielkarten}            63 x 88 mm, eine Seite je Kartenseite
%%%   \documentclass[anschnitt]{dsa5spielkarten} 69 x 94 mm, mit Anschnitt
%%%   \documentclass[bogen]{dsa5spielkarten}     A4, 3 x 3 Karten, duplexdeckend
%%%
%%% Copyright 2026 Leif Janzik. Apache License 2.0, siehe LICENSE.
%%%
%%% Das Bildmaterial und die Schriften sind NICHT Teil dieses Projekts. Sie
%%% gehoeren Ulisses Spiele und stehen unter der Vereinbarung ueber
%%% Gemeinschaftsinhalte fuer SCRIPTORIUM AVENTURIS. Vor dem ersten Lauf:
%%%
%%%   python3 werkzeuge/aufbereiten.py  "/pfad/zu/Scriptorium Aventuris v4"
%%%   python3 werkzeuge/kartengrafik.py "/pfad/zu/Scriptorium Aventuris -Spielkarten"
%%%
%%% BEIDE Ulisses-Pakete werden gebraucht, und der allgemeine Layout-
%%% Baukasten ist dabei nicht der entbehrliche:
%%%
%%%   aus dem Spielkarten-Baukasten  die Kartenflaeche
%%%   aus dem Layout-Baukasten       Gentium Basic fett und kursiv,
%%%                                  dazu die Rautenkacheln des Ruckens
%%%
%%% Das Kartenpaket bringt in „Document fonts" zwar Schriften mit, aber nur
%%% GenBasR und andlso. Fett und kursiv fehlen dort, und die braucht jedes
%%% Stichwort einer Karte. Naeheres in doku/SPIELKARTEN.md. Ohne beide
%%% Pakete kompiliert nichts.
%%%
%%% Woher die Masse kommen: doku/MASSE.md, Abschnitt 9. Kurz — der
%%% Spielkarten-Baukasten bringt eine IDML mit genau einem Bildrahmen, genau
%%% einem Textrahmen und drei Absatzformaten. Das Bild liegt darin mit
%%% ActualPpi = EffectivePpi = 300, also unskaliert; damit sind Rahmenmasse
%%% und Pixelmasse beide belastbar und sagen dasselbe.
%%%
%%% Was der Baukasten NICHT hergibt — Wertetabelle, Attributraster,
%%% Medaillon, Kartennummer, Illustrationsnachweis — ist an den beiden
%%% veroeffentlichten Kartensets gemessen: „Aventurische Meisterpersonen"
%%% (2017, 53 Karten) und „Flusslande" (2018, 126 Karten). Beide liegen
%%% nicht in diesem Projekt; sie dienten nur zum Ausmessen. Wo ein Mass von
%%% dort kommt, steht das Set daneben.
%%%
%%% Zur Einheit: alle Masse aus dem Baukasten sind bp, PostScript-Punkte zu
%%% 1/72 Zoll — so rechnet InDesign. Ein TeX-Punkt ist 0,4 Prozent kleiner.
%%% Am Schriftgrad sieht man das nicht, am Durchschuss schon: eine volle
%%% Kartenrueckseite hat 25 Zeilen, und mit 8 pt statt 8 bp laege die letzte
%%% um 0,8 bp daneben.

\NeedsTeXFormat{LaTeX2e}
\ProvidesClass{dsa5spielkarten}[2026/09/25 v1.0 Spielkarten im DSA5-Layout]

%%% ==================================================================
%%% 1  Optionen
%%% ==================================================================
%
% Zwei Druckfassungen:
%
%   einzeln   Seite = Karte, 63 x 88 mm. Fuer die Druckerei, die auf
%             Kartenformat schneidet, und fuer den Blick am Bildschirm.
%   bogen     Seite = A4 mit 3 x 3 Karten, Vorder- und Rueckseitenbogen im
%             Wechsel. Fuer den eigenen Drucker.
%
% Dazu „anschnitt": die Seite wird 69 x 94 mm, und die Kartenflaeche fuellt
% sie bis zum Blattrand — das, was eine Druckerei als „mit 3 mm Beschnitt"
% erwartet. Beim Bogen ist die Option wirkungslos, dort wird auf
% Schnittmarken geschnitten.

\newif\ifdsa@bogen         \dsa@bogenfalse
\newif\ifdsa@anschnitt     \dsa@anschnittfalse
\newif\ifdsa@schnittmarken \dsa@schnittmarkentrue
\newif\ifdsa@kurz          \dsa@kurzfalse
\newif\ifdsa@entwurf       \dsa@entwurffalse

\DeclareOption{einzeln}{\dsa@bogenfalse}
\DeclareOption{bogen}{\dsa@bogentrue}
\DeclareOption{anschnitt}{\dsa@anschnitttrue}
\DeclareOption{schnittmarken}{\dsa@schnittmarkentrue}
\DeclareOption{ohneschnittmarken}{\dsa@schnittmarkenfalse}
% Wenden an der kurzen statt an der langen Kante. Siehe Abschnitt 16.
\DeclareOption{kurz}{\dsa@kurztrue}
\DeclareOption{entwurf}{\dsa@entwurftrue}
\DeclareOption*{\PassOptionsToClass{\CurrentOption}{article}}
\ProcessOptions\relax

% Basis ist article, einspaltig. Eine Karte hat keinen Satzspiegel im Sinne
% der Kernklasse: jedes Element sitzt an einer gemessenen Stelle, gesetzt
% wird in TikZ. article liefert nur die Absatz- und Schriftmaschinerie.
\LoadClass[10pt]{article}

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
\RequirePackage{etoolbox}
\RequirePackage{textcomp}

\ifdsa@entwurf \setkeys{Gin}{draft} \fi

% Kein Mathematik-Schriftpaket, aus demselben Grund wie in dsa5latex.cls:
% eine Karte braucht keinen Formelsatz. Wuerfelangaben sind Text.
\newcommand*{\dsaFormel}[1]{\mbox{#1}}
\newcommand*{\dsaMod}[2]{\mbox{\dsa@vorzeichen{#1}#2}}
\newcommand*{\dsa@vorzeichen}[1]{\if-#1\textminus\else#1\fi}
\newcommand*{\dsaMinus}{\textminus}

%%% ==================================================================
%%% 3  Sprache
%%% ==================================================================
%
% Ohne Sprachunterstuetzung trennt LaTeX deutschen Text nach englischen
% Mustern. Bei 52 mm Satzbreite faellt das staerker auf als im Heft: eine
% Zeile fasst sechs bis acht Woerter, und jede schlechte Trennung reisst
% eine sichtbare Luecke.

\setdefaultlanguage[spelling=new]{german}

%%% ==================================================================
%%% 4  Grafikpfad
%%% ==================================================================
%
% Wie in dsa5latex.cls: alle Grafiken liegen in grafiken/, gesucht wird
% neben dem Dokument und eine Ebene hoeher, damit ein Satz auch aus
% beispiel/ heraus laeuft.

\newcommand*{\dsagrafik}[1]{grafiken/#1}
\graphicspath{{./}{../}}
\DeclareGraphicsExtensions{.jpg,.jpeg,.png,.pdf}

%%% ==================================================================
%%% 5  Schriften
%%% ==================================================================
%
% Der Spielkarten-Baukasten bringt in „Document fonts" genau zwei Schriften
% mit, und es sind dieselben wie im allgemeinen Baukasten: andlso.ttf
% (Andalus) und GenBasR.ttf (Gentium Basic). Die drei Absatzformate seiner
% Styles.xml benutzen beide:
%
%   Ueberschrift   Andalus,      14 pt auf 12 pt, zentriert, Versalien
%   Untertitel     Andalus,       7 pt auf 8,4 pt, zentriert, Versalien
%   Beschreibung   Gentium Basic, 7 pt auf 8 pt, Blocksatz
%
% Alle drei mit Tracking 10. InDesign zaehlt Tracking in Tausendstel
% Geviert, 10 davon sind 1 Prozent des Schriftgrads; fontspec zaehlt
% LetterSpace in Prozent, also LetterSpace=1.0. Es gilt hier fuer beide
% Familien, weil der Baukasten es fuer alle drei Formate setzt.
%
% Die beiden veroeffentlichten Sets sind in Times New Roman gesetzt, nicht
% in Gentium Basic. Times liegt weder im Baukasten noch im Kartenpaket und
% darf hier nicht mitgeliefert werden; gesetzt wird deshalb in der Schrift,
% die der Kartenbaukasten selbst vorgibt. Das ist kein Kompromiss, sondern
% der Vorlage naeher: der Baukasten ist die Vorlage, die Sets sind Produkte.

\defaultfontfeatures{Ligatures=TeX}

% Der Ordner mit den Schriften: erst neben dem Dokument, dann eine Ebene
% hoeher. Beide Pfade beginnen mit ./ — ohne den Punkt sucht kpathsea den
% Namen in TEXINPUTS mit und meldet eine Datei, die fontspec danach nicht
% oeffnen kann. Ausfuehrlich begruendet in dsa5latex.cls, Abschnitt 5.
\IfFileExists{./schriften/GenBasR.ttf}
  {\newcommand*{\dsa@schriften}{./schriften/}}
  {\IfFileExists{./../schriften/GenBasR.ttf}
     {\newcommand*{\dsa@schriften}{../schriften/}}
     {\newcommand*{\dsa@schriften}{./schriften/}%
      \ClassWarning{dsa5spielkarten}{Der Ordner schriften/ ist weder neben
        dem Dokument noch eine Ebene hoeher zu finden. Erzeugen mit
        werkzeuge/aufbereiten.py}}}

\setmainfont{GenBasR}[
  Path           = \dsa@schriften,
  Extension      = .ttf,
  BoldFont       = GenBasB,
  ItalicFont     = GenBasI,
  BoldItalicFont = GenBasBI,
  LetterSpace    = 1.0 ]

% Andalus hat nur einen Schnitt; ohne AutoFakeBold faellt \textbf still auf
% den normalen zurueck. Dasselbe Verfahren wie in dsa5latex.cls.
\newfontfamily{\dsaandalus}{andlso}[
  Path          = \dsa@schriften,
  Extension     = .ttf,
  AutoFakeBold  = 1.5,
  AutoFakeSlant = 0.2,
  LetterSpace   = 1.0 ]

% Die Grundschrift der Karte ist das Format „Beschreibung": 7 bp auf 8 bp.
% \normalsize ist der Haken, den LaTeX fuer die Grundschrift zieht; wer ihn
% nicht umdefiniert, bekommt bei jedem \selectfont die 10 pt auf 12 pt der
% Basisklasse zurueck.
\newcommand*{\dsakartengrad}{7}
\newcommand*{\dsakartendurchschuss}{8}
\renewcommand{\normalsize}{%
  \@setfontsize\normalsize{\dsakartengrad bp}{\dsakartendurchschuss bp}%
  \abovedisplayskip\z@ \belowdisplayskip\z@
  \abovedisplayshortskip\z@ \belowdisplayshortskip\z@}
\AtBeginDocument{\normalsize}

% Wie in dsa5latex.cls: ohne Mathematik-Schriftpaket leitet LaTeX die drei
% Mathematik-Groessen mit 0,7 und 0,5 aus der Grundgroesse ab und sucht
% Computer-Modern-Grade, die es nicht gibt. Am Satz aendert das nichts, die
% Warnungen bleiben trotzdem aus.
\DeclareMathSizes{5.5bp}{5.5bp}{5bp}{5bp}
\DeclareMathSizes{6bp}{6bp}{5bp}{5bp}
\DeclareMathSizes{7bp}{7bp}{5bp}{5bp}
\DeclareMathSizes{14bp}{14bp}{10bp}{7bp}

%%% ==================================================================
%%% 6  Farben
%%% ==================================================================
%
% Der Spielkarten-Baukasten hat keine eigene Palette: seine Graphic.xml
% enthaelt nur die Prozessfarben, die InDesign in jedem neuen Dokument
% anlegt, und der Text steht in Schwarz. Die beiden Farben unten stammen
% deshalb aus den veroeffentlichten Sets.
%
%   dsakartenschrift  #231F20 — der Textton beider Sets. Nicht reines
%                     Schwarz; so exportiert InDesign CMYK 0/0/0/100 mit dem
%                     Standardprofil, und so sieht der Leser es. Derselbe
%                     Wert wie im Heft.
%   dsakartenzeile    #DDCEC9 — der Wechselton der Wertetabelle, an der
%                     Fuellung im Flusslande-Set gemessen (PDF-Fuellfarbe
%                     0,866 / 0,809 / 0,7865).
\definecolor{dsakartenschrift}{HTML}{231F20}
\definecolor{dsakartenzeile}{HTML}{DDCEC9}

%%% ==================================================================
%%% 7  Kartenmasse und Seitenformat
%%% ==================================================================
%
% Aus Resources/Preferences.xml der Baukasten-IDML, unveraendert:
%   PageWidth  178,58267716535434 bp = 63 mm
%   PageHeight 249,44881889763780 bp = 88 mm
%   DocumentBleedTopOffset und die drei anderen: 0
%
% Der Baukasten legt also selbst keinen Anschnitt an — den bringt die
% Kartenflaeche mit, siehe Abschnitt 9.
\newlength{\dsakartenbreite}   \setlength{\dsakartenbreite}{63mm}
\newlength{\dsakartenhoehe}    \setlength{\dsakartenhoehe}{88mm}

% Der Anschnitt, den die Flaechengrafik mitbringt: 195,6 bp Bild gegen
% 178,583 bp Karte sind 8,5085 bp Ueberstand je Seite, also 3,00 mm;
% 266,4 gegen 249,449 sind 8,4756 bp, also 2,99 mm. Die IDML bestaetigt das
% im FrameFittingOption des Bildrahmens mit LeftCrop 8,51338582677164 und
% TopCrop 8,447244094488155.
\newlength{\dsakartenanschnittx} \setlength{\dsakartenanschnittx}{3.00mm}
\newlength{\dsakartenanschnitty} \setlength{\dsakartenanschnitty}{2.99mm}

\newlength{\dsa@seitenbreite}
\newlength{\dsa@seitenhoehe}
\ifdsa@bogen
  \setlength{\dsa@seitenbreite}{210mm}
  \setlength{\dsa@seitenhoehe}{297mm}
\else
  \ifdsa@anschnitt
    \setlength{\dsa@seitenbreite}{\dimexpr\dsakartenbreite+2\dsakartenanschnittx\relax}
    \setlength{\dsa@seitenhoehe}{\dimexpr\dsakartenhoehe+2\dsakartenanschnitty\relax}
  \else
    \setlength{\dsa@seitenbreite}{\dsakartenbreite}
    \setlength{\dsa@seitenhoehe}{\dsakartenhoehe}
  \fi
\fi
\geometry{papersize={\dsa@seitenbreite,\dsa@seitenhoehe}, margin=0pt,
          nohead, nofoot, noheadfoot}
\pagestyle{empty}
\setlength{\parindent}{0pt}

% \topskip=0pt und eine Kartenbox ohne Hoehe ueber der Grundlinie: dann
% sitzt die Oberkante der Box genau auf der Oberkante des Satzbereichs, und
% der ist wegen margin=0pt das Blatt. Ohne das schoebe TeX die erste Zeile
% um \topskip nach unten, und jede Karte laege 10 pt zu tief.
\setlength{\topskip}{0pt}
\setlength{\parskip}{0pt}

%%% ==================================================================
%%% 8  Der Textrahmen
%%% ==================================================================
%
% Aus Spreads/Spread_uce.xml der Baukasten-IDML. Der einzige Textrahmen
% (TextFrame uf6) hat ItemTransform 1 0 0 1 -5,787401574803141
% -15,141732283464563 und die vier Ankerpunkte (-75|-75), (-75|106,98425),
% (86,57480|106,98425), (86,57480|-75). Die Seite liegt mit ItemTransform
% -89,29133858267717 -124,7244094488189 auf dem Spread, der Spread-Ursprung
% ist also die Kartenmitte. In Seitenkoordinaten ergibt das:
%
%   links   8,50394 bp =  3,00 mm      oben  34,58268 bp = 12,20 mm
%   rechts 170,07874 bp = 60,00 mm     unten 216,56693 bp = 76,40 mm
%
% Breite 57,00 mm, Hoehe 64,20 mm. InsetSpacing ist viermal 0,
% TextColumnCount 1 und TextColumnFixedWidth 161,5748 bp = 57,00 mm —
% beides bestaetigt die Rechnung.
\newlength{\dsakartenrahmenlinks}  \setlength{\dsakartenrahmenlinks}{3.00mm}
\newlength{\dsakartenrahmenoben}   \setlength{\dsakartenrahmenoben}{12.20mm}
\newlength{\dsakartenrahmenbreite} \setlength{\dsakartenrahmenbreite}{57.00mm}
\newlength{\dsakartenrahmenhoehe}  \setlength{\dsakartenrahmenhoehe}{64.20mm}
% Die Unterkante ausgeschrieben, weil der Verbrauchsgegenstand seinen Text
% daran aufhaengt: er waechst von unten nach oben, und die untere
% Rahmenkante ist die Linie, an der das Pergament in den Zierrand uebergeht.
\newlength{\dsakartenrahmenunten} \setlength{\dsakartenrahmenunten}{76.40mm}

% Das Absatzformat „Beschreibung" zieht links und rechts je 7,086614173 bp
% ein, das sind genau 2,50 mm. Die gesetzte Zeile ist damit 52,00 mm breit
% und beginnt bei 5,50 mm. Am Baukasten-PDF nachgemessen liegt die linke
% Satzkante bei 15,586 bp = 5,498 mm — zwei Hundertstel Millimeter daneben,
% das ist die Seitenlagerung des ersten Buchstabens.
\newlength{\dsakarteneinzug}     \setlength{\dsakarteneinzug}{2.50mm}
\newlength{\dsakartensatzlinks}  \setlength{\dsakartensatzlinks}{5.50mm}
\newlength{\dsakartensatzbreite} \setlength{\dsakartensatzbreite}{52.00mm}

% Die erste Grundlinie der Vorderseite. Am Baukasten-PDF gemessen: die
% Ueberschrift sitzt auf 50,053 bp = 17,657 mm unter der Papieroberkante.
%
% Warum ein festes Mass und nicht Rahmenoberkante plus Zeilenhoehe:
% InDesign setzt die erste Grundlinie auf „Oberlaenge" — den Abstand, den
% die groesste Oberlaenge der ersten Zeile braucht. TeX rechnet dafuer die
% Hoehe der tatsaechlich gesetzten Glyphen, und die haengt am Text: fuer
% „EINE UEBERSCHRIFT" in Andalus 14 bp sind es 10,004 pt, mit einem Umlaut
% darin mehr. Die erste Zeile saesse also je nach Name anders hoch. Deshalb
% wird der Textfluss an seiner ersten Grundlinie aufgehaengt, nicht an
% seiner Oberkante — so liegen die Namen aller Karten auf einer Hoehe.
\newlength{\dsakartenerstezeile} \setlength{\dsakartenerstezeile}{17.657mm}

% Die erste Grundlinie der Rueckseite. Nicht im Baukasten — er zeigt nur
% eine Anordnung, und die beginnt mit der Ueberschrift. Gemessen am
% Flusslande-Set, wo jede Rueckseite ohne Tabelle mit Fliesstext beginnt:
% 41,924 bp = 14,790 mm, auf 33 von 126 Karten genau so und auf den
% uebrigen nur dort hoeher, wo der Satz zu lang wurde.
\newlength{\dsakartenrueckzeile} \setlength{\dsakartenrueckzeile}{14.790mm}

%%% ==================================================================
%%% 9  Die Kartenflaeche
%%% ==================================================================
%
% Links/Spielkarte_Ulisses_Design.tif, 815 x 1110 px bei 300 ppi, im
% Bildrahmen der IDML mit ActualPpi = EffectivePpi = 300 abgelegt, also
% unskaliert. 815/300*25,4 = 69,003 mm, 1110/300*25,4 = 93,980 mm; die
% GraphicBounds der IDML nennen dieselben Masse in bp: 195,6 x 266,4. Das
% Bild sitzt mittig auf der Karte (ItemTransform -97,8 -133,2, die halben
% Bildmasse).
\newlength{\dsakartenflaechebreite} \setlength{\dsakartenflaechebreite}{69.003mm}
\newlength{\dsakartenflaechehoehe}  \setlength{\dsakartenflaechehoehe}{93.980mm}

% werkzeuge/kartengrafik.py legt sie als spielkarte-flaeche.png ab, die
% eingefaerbten Fassungen als spielkarte-flaeche-<farbe>.png. Umstellen mit
% \dsaKartenflaeche{spielkarte-flaeche-blau}, auch mitten im Dokument —
% dann hat der naechste Kartensatz eine andere Randfarbe.
\newcommand*{\dsa@kartenflaeche}{spielkarte-flaeche}
\newcommand*{\dsaKartenflaeche}[1]{\renewcommand*{\dsa@kartenflaeche}{#1}}

% Rand und Ruecken in einem Zug. \dsaKartenfarbe{blau} nimmt
% spielkarte-flaeche-blau fuer die Karte und spielkarte-raute-blau fuer die
% Raute des Ruckens -- beide legt werkzeuge/kartengrafik.py mit --farbe an,
% und beide tragen denselben Farbton. Ohne Argument gilt wieder die
% unbehandelte Fassung des Baukastens.
%
% \dsaKartenraute steht weiter fuer sich, wer die Raute eigens waehlen will
% (die drei amtlichen Kacheln heissen raute-grau, raute-gruen, raute-rot).
\newcommand{\dsaKartenfarbe}[1]{%
  \ifstrempty{#1}%
    {\dsaKartenflaeche{spielkarte-flaeche}\dsaKartenraute{raute-grau}}%
    {\dsaKartenflaeche{spielkarte-flaeche-#1}%
     \dsaKartenraute{spielkarte-raute-#1}}}

% Die Flaeche des generischen Ruckens. Vorgabe ist dieselbe wie vorne;
% spielkarte-ruecken ist die bandlose Ableitung, die
% werkzeuge/kartengrafik.py miterzeugt.
%
% Warum es die gibt: schwarzer Rand, Schuppenband, Messingecken und
% Pergament stecken in EINER flachen Datei -- das TIF des Baukastens ist
% RGB, eine Ebene, ohne Alphakanal. Abschalten laesst sich das Band also
% nicht. Ersetzen schon: das Werkzeug fuellt die Bandzone mit Pergament aus
% der Kartenmitte und baut den dunklen Rand neu auf. Uebrig bleibt eine
% ruhige Pergamentkarte, auf der die Raute allein steht — und die Farbe
% traegt dann die Raute, nicht der Rand.
%
% Leer heisst: dieselbe Flaeche wie die Vorderseite.
\newcommand*{\dsa@rueckflaeche}{}
\newcommand*{\dsaKartenrueckflaeche}[1]{%
  \renewcommand*{\dsa@rueckflaeche}{#1}}

%%% ==================================================================
%%% 10  Ein Kartenblatt zeichnen
%%% ==================================================================
%
% Jede Kartenseite wird in eine Box gesetzt, die genau 63 x 88 mm misst.
% Innen wird in Millimetern von der oberen linken Ecke gerechnet, y nach
% unten negativ — dieselbe Rechnung wie in dsa5aufsteller.sty, damit beide
% Erweiterungen gleich zu lesen sind.
%
% Der Zuschnitt auf die Kartenkante steht ausdruecklich drin: die
% Flaechengrafik ragt 3 mm ueber, und ohne \clip liefe sie auf dem Bogen in
% die Nachbarkarte.
%
% baseline=0pt (die Vorgabe) legt die Grundlinie der Box auf y=0, also auf
% die Oberkante der Karte. Die Box hat damit Hoehe 0 und Tiefe 88 mm — das
% ist es, was \topskip=0pt in Abschnitt 7 braucht.
% #1 Flaechengrafik, #2 Inhalt
\newcommand{\dsa@kartenblattauf}[2]{%
  \begin{tikzpicture}
    \useasboundingbox (0,0) rectangle (\dsakartenbreite,-\dsakartenhoehe);
    \begin{scope}
      \clip (0,0) rectangle (\dsakartenbreite,-\dsakartenhoehe);
      \node[anchor=center, inner sep=0, outer sep=0]
        at (0.5\dsakartenbreite,-0.5\dsakartenhoehe)
        {\includegraphics[width=\dsakartenflaechebreite,
                          height=\dsakartenflaechehoehe]%
                         {\dsagrafik{#1}}};
      #2
    \end{scope}
  \end{tikzpicture}}

\newcommand{\dsa@kartenblatt}[1]{%
  \dsa@kartenblattauf{\dsa@kartenflaeche}{#1}}
% Breite UND Hoehe an \includegraphics: das streckt normalerweise und ist
% in diesem Projekt sonst verboten (siehe \dsaBildDeckend in dsa5latex.cls).
% Hier ist es richtig — die Grafik hat genau dieses Seitenverhaeltnis, die
% doppelte Angabe haelt sie nur fest, falls jemand eine eigene Flaeche
% einsetzt, die ein paar Pixel daneben liegt.

%%% ==================================================================
%%% 11  Der Textfluss
%%% ==================================================================
%
% Der Textrahmen als \vtop: dessen Bezugspunkt ist die Grundlinie der
% ERSTEN Zeile. Genau das wird gebraucht, um ihn an der gemessenen ersten
% Grundlinie aufzuhaengen (Abschnitt 8).
%
% \hsize ist die Satzbreite, nicht die Rahmenbreite — der Einzug von 2,5 mm
% je Seite steckt schon darin. Deshalb setzt der Fluss bei
% \dsakartensatzlinks an und nicht bei \dsakartenrahmenlinks.
% Die Textfarbe kommt als Knotenoption, nicht als \color im \vtop. Das ist
% kein Geschmack, sondern Bedingung: \color legt in senkrechtem Modus einen
% Whatsit auf die Liste. Die Liste ist damit nicht mehr leer, TeX schiebt
% vor dem ersten Absatz \parskip ein — und die Hoehe eines \vtop ist nur
% dann die Hoehe seiner ersten Zeile, wenn das erste Element ein Kasten ist.
% Mit dem Whatsit davor wird sie null, der Bezugspunkt rutscht auf die
% Oberkante, und der ganze Satz stand 3,58 mm zu tief — genau die
% Oberlaenge der 14-bp-Zeile. Am gesetzten PDF gemessen, nicht geraten.
\newcommand{\dsa@kartenfluss}[2]{%
  \node[anchor=base west, inner sep=0, outer sep=0,
        text=dsakartenschrift]
    at (\dsakartensatzlinks,-#1)
    {\vtop{\hsize=\dsakartensatzbreite
           \parindent=0pt \parskip=0pt
           \dsa@engersatz
           \normalsize
           #2}};}

% Blocksatz auf 52 mm ist etwas anderes als Blocksatz auf 80,5 mm. Eine
% Kartenzeile fasst sechs bis acht Woerter; ein einziges langes Wort sprengt
% sie. Mit den Vorgaben von LaTeX standen acht Zeilen des Beispiels ueber,
% die schlimmste um 8,12 pt — knapp 3 mm, also mitten im Zierrand.
%
% Deshalb: mehr Trennung zulassen und lieber eine lockere Zeile hinnehmen
% als eine ueberlaufende. \emergencystretch gibt TeX einen dritten Durchgang
% mit zusaetzlichem Dehnraum, bevor es aufgibt und den Rand ueberschreibt.
%
% Die Werte sind nicht gegriffen, sondern die mildesten, mit denen keine
% Zeile mehr ueberlaeuft. Durchprobiert am Beispieldokument:
%
%   tolerance  emergencystretch   ueberlaufend        locker
%   2000       1em                1 (6,91 pt)         2
%   3000       2em                0                   3
%   4000       2em                0                   3
%   9999       3em                0                   3
%
% Ab 3000/2em aendert sich nichts mehr; hoehere Werte kaufen also nur
% loechrigere Zeilen ein, ohne etwas zu gewinnen.
\newcommand{\dsa@engersatz}{%
  \tolerance=3000
  \emergencystretch=2em
  \hyphenpenalty=50
  \doublehyphendemerits=2500
  % Die Vorgabe waeren zwei Trennungen in Folge. Auf dieser Breite ist das
  % zu wenig; drei sind hier die Regel, nicht die Ausnahme.
  \righthyphenmin=3 \lefthyphenmin=2 }

% Absatzabstand des Formats „Beschreibung": SpaceAfter 2,834645669291339 bp
% = 1,00 mm. Gesetzt wird er als \vskip VOR jedem weiteren Absatz, nicht
% als \parskip — \parskip gaelte auch vor dem ersten und verschoebe die
% erste Grundlinie um genau diesen Betrag.
\newlength{\dsakartenabsatzluft} \setlength{\dsakartenabsatzluft}{2.834646bp}

\newif\ifdsa@ersterabsatz \dsa@ersterabsatztrue
\newcommand{\dsa@absatzluft}{%
  \ifdsa@ersterabsatz \global\dsa@ersterabsatzfalse
  \else \par\vskip\dsakartenabsatzluft\fi}

% Ein Absatz im Format „Beschreibung". InDesign nennt seinen Blocksatz mit
% linksbuendiger letzter Zeile „LeftJustified", und das ist LaTeX' Vorgabe —
% deshalb steht hier kein \raggedright.
\newcommand{\dsaKartenabsatz}[1]{%
  \dsa@absatzluft
  {#1\par}}

% Ein Absatz mit hervorgehobenem Stichwort und haengendem Einzug.
%
% Beide Sets setzen ihre Stichwortabsaetze so, aber nicht gleich:
% „Meisterpersonen" kursiv („Charakterzuege:"), „Flusslande" fett
% („Waffenvorteil:"). Hier gilt fett, das juengere Set. Der haengende
% Einzug ist in beiden 2,5 mm — im Meisterpersonen-Set von 17,008 bp auf
% 24,093 bp, also 7,085 bp.
\newlength{\dsakartenhaengend} \setlength{\dsakartenhaengend}{2.50mm}
\newcommand{\dsaKarteStich}[2]{%
  \dsa@absatzluft
  {\hangindent=\dsakartenhaengend \hangafter=1
   \textbf{#1:} #2\par}}

%%% ==================================================================
%%% 12  Kartenkopf: Ueberschrift und Untertitel
%%% ==================================================================
%
% Absatzformat „Ueberschrift" (IDML Styles.xml):
%   AppliedFont Andalus, PointSize 14, Leading 12,
%   Justification CenterAlign, Capitalization AllCaps, Tracking 10
%
% Absatzformat „Untertitel":
%   AppliedFont Andalus, PointSize 7, Leading automatisch — InDesign nimmt
%   dafuer 120 Prozent, also 8,4 bp, und das Baukasten-PDF bestaetigt es:
%   58,453 minus 50,053 bp sind genau 8,400. Dazu CenterAlign, AllCaps,
%   Tracking 10 und SpaceAfter 6,236220472440945 bp = 2,20 mm.
%
% Der Zeilenabstand 12 bp bei 14 bp Grad ist enger als der Grad. Das ist
% Absicht und fuer zweizeilige Namen gedacht: Versalien haben keine
% Unterlaengen, die Zeilen stossen nicht zusammen. Beide Sets setzen ihre
% zweizeiligen Namen genau so, gemessen 11,998 bp.
\newlength{\dsakartenuntertitelluft}
\setlength{\dsakartenuntertitelluft}{6.236220bp}

% \MakeUppercase bildet Capitalization=AllCaps nach: der Name wird gemischt
% uebergeben und hier versal gesetzt, wie InDesign es tut. So bleibt er im
% Quelltext lesbar — „Oldewin" statt „OLDEWIN".
\newcommand{\dsaKartenkopf}[2]{%
  {\dsaandalus\fontsize{14bp}{12bp}\selectfont
   \centering\MakeUppercase{#1}\par}%
  \ifstrempty{#2}{}{%
    {\dsaandalus\fontsize{7bp}{8.4bp}\selectfont
     \centering\MakeUppercase{#2}\par}%
    \vskip\dsakartenuntertitelluft}%
  \global\dsa@ersterabsatzfalse}

%%% ==================================================================
%%% 13  Die Wertetabelle
%%% ==================================================================
%
% Nicht im Baukasten — gemessen am Flusslande-Set, dort auf jeder Waffen-
% und Ruestungskarte. Die Fuellrechtecke liegen im PDF offen:
%
%   Zeilenhoehe   11,339 bp = 4,00 mm, ausnahmslos
%   Kopfzeile     ebenso 4,00 mm
%   Fuellung      jede zweite Zeile, beginnend mit der Kopfzeile
%   Spalten       Trennung bei 77,953 bp, also 19,00 mm hinter der linken
%                 Tabellenkante bei 24,094 bp
%
% Uebernommen sind Zeilenhoehe und Wechselton unveraendert. Lage und Breite
% richten sich nach dem Satzspiegel des Baukastens (52 mm ab 5,5 mm) statt
% nach den 46 mm des Sets, damit Tabelle und Fliesstext auf derselben Kante
% stehen.
%
% Die Spaltenteilung wird deshalb nicht uebernommen, sondern mitskaliert:
% 19,00 von 46,00 mm sind 41,3 Prozent, auf 52,00 mm also 21,48 mm. Die
% 19 mm des Sets stehen auf dieser Breite zu eng — „zusaetzliche Abzuege"
% stiess auf der Ruestungskarte in die Wertespalte, weil Gentium Basic
% breiter laeuft als das Times des Sets.
\newlength{\dsakartenzeilenhoehe} \setlength{\dsakartenzeilenhoehe}{4mm}
\newlength{\dsakartenwertspalte}  \setlength{\dsakartenwertspalte}{21.48mm}

% Oberkante der Tabelle: die Oberkante des Textrahmens. Das Set setzt sie
% auf 13,20 mm, der Baukastenrahmen beginnt bei 12,20 mm; hier gilt der
% Baukasten, damit Tabelle und Fliesstext denselben Rahmen benutzen.
\newlength{\dsakartentabelleoben}
\setlength{\dsakartentabelleoben}{\dsakartenrahmenoben}

% Gesammelt wird zeilenweise, gezeichnet am Stueck: erst dann steht fest,
% wie viele Zeilen es sind und welche gefuellt gehoert.
\newcount\dsa@wertzeile
\newlength{\dsa@wertunten}
\newcommand{\dsa@werteliste}{}
\newcommand{\dsa@wertekopf}{}
\newcommand{\dsaKartenwert}[2]{\listgadd{\dsa@werteliste}{{#1}{#2}}}
\newcommand{\dsaKartenwertkopf}[1]{\renewcommand{\dsa@wertekopf}{#1}}

% Die Tabelle setzt kleiner als der Fliesstext, und zwar in den Graden des
% Sets: Beschriftung 6 bp fett, Wert 6,5 bp. Der Baukasten sagt dazu nichts
% — er kennt die Tabelle nicht —, also gilt hier durchgehend das Set, aus
% dem auch Zeilenhoehe, Wechselton und Spaltenteilung stammen.
%
% Es ist ausserdem das, was passt: mit den 7 bp des Fliesstexts stiess
% „zusaetzliche Abzuege" auf der Ruestungskarte in die Wertespalte. Gentium
% Basic laeuft breiter als das Times des Sets, und 19 mm Beschriftungsspalte
% sind auf diesen Grad gerechnet.
\newcommand{\dsakartentabellenschrift}{\fontsize{6bp}{7bp}\selectfont}
\newcommand{\dsakartenwertschrift}{\fontsize{6.5bp}{7.8bp}\selectfont}

\newlength{\dsa@wy}
\newcommand{\dsa@wertzeichne}[1]{\dsa@wertzeichneB#1}
\newcommand{\dsa@wertzeichneB}[2]{%
  \setlength{\dsa@wy}{\dimexpr-\dsakartentabelleoben
                      -\the\dsa@wertzeile\dsakartenzeilenhoehe\relax}%
  \ifodd\dsa@wertzeile\else
    \fill[dsakartenzeile]
      (\dsakartensatzlinks,\dsa@wy)
      rectangle ($(\dsakartensatzlinks,\dsa@wy)
                  +(\dsakartensatzbreite,-\dsakartenzeilenhoehe)$);
  \fi
  % Beschriftung und Wert stehen senkrecht mittig in der 4 mm hohen Zeile.
  % Das Set setzt die Grundlinie 2,72 mm unter die Zeilenoberkante; bei
  % 6,5 bp Schrift ist das die optische Mitte, und anchor=west stellt sie
  % her, ohne den Wert an einen fremden Schriftgrad zu binden.
  \node[anchor=west, inner sep=0, outer sep=0]
    at ($(\dsakartensatzlinks,\dsa@wy)+(1mm,-0.5\dsakartenzeilenhoehe)$)
    {\color{dsakartenschrift}\dsakartentabellenschrift\bfseries #1};
  \node[anchor=west, inner sep=0, outer sep=0]
    at ($(\dsakartensatzlinks,\dsa@wy)
         +(\dsakartenwertspalte,-0.5\dsakartenzeilenhoehe)$)
    {\color{dsakartenschrift}\dsakartenwertschrift #2};
  \global\advance\dsa@wertzeile by 1\relax}

\newcommand{\dsa@wertetabelle}{%
  \global\dsa@wertzeile=0\relax
  \ifdefempty{\dsa@werteliste}{}{%
    % Die Kopfzeile ist Zeile 0 und damit gefuellt. Sie traegt den Namen
    % des Gegenstands ueber die ganze Breite, deshalb ein leerer Wert.
    \dsa@wertzeichne{{\dsa@wertekopf}{}}%
    \forlistloop{\dsa@wertzeichne}{\dsa@werteliste}}%
  \global\dsa@wertunten=\dimexpr\dsakartentabelleoben
    +\the\dsa@wertzeile\dsakartenzeilenhoehe\relax}

%%% ==================================================================
%%% 14  Das Attributraster der Monsterkarte
%%% ==================================================================
%
% Nicht im Baukasten — gemessen am Flusslande-Set, dort auf jeder
% Kreaturenkarte. Vier Spalten mit den Tabulatoren bei 17,0 / 53,0 / 89,0 /
% 125,0 bp, also Schritt 36 bp = 12,70 mm, Zeilenschritt 7,8 bp (der
% Durchschuss ihres 6,5-bp-Satzes).
%
% Uebernommen ist der Spaltenschritt. Der Zeilenschritt ist hier der
% Durchschuss dieser Klasse (8 bp, Baukasten), damit das Raster auf
% denselben Zeilen sitzt wie der Fliesstext darunter.
%
% Der Abstand vom Kuerzel zum Wert steht im Set auf einem Tabulator, den
% die Karten zwischen 2,5 und 4,3 mm ansetzen — je nach Breite des
% Kuerzels. Gesetzt sind hier 4,5 mm: das laesst auch „LeP" und „AsP"
% freien Lauf.
\newlength{\dsakartenspaltenschritt} \setlength{\dsakartenspaltenschritt}{12.70mm}
\newlength{\dsakartenwertversatz}    \setlength{\dsakartenwertversatz}{4.50mm}

% Der Zeilenschritt als Laenge, nicht als „\dsakartendurchschuss bp". Das
% ist kein Geschmack: \dsakartendurchschuss ist ein Makro, das zur Ziffer 8
% expandiert, und „\the\@tempcnta\dsakartendurchschuss bp" ergibt fuer
% Zeile 0 nicht 0 mal 8 bp, sondern die aneinandergehaengten Ziffern 0 und 8
% — also 8 bp. Am gesetzten PDF stand das Raster deshalb 2,82 mm zu tief.
% Vor einer Laenge steht der Zaehler als Faktor, vor einer Ziffer nicht.
\newlength{\dsakartenzeilenschritt}
\setlength{\dsakartenzeilenschritt}{\dsakartendurchschuss bp}

\newcount\dsa@attrzaehler
\newlength{\dsa@attrunten}
\newcommand{\dsa@attrliste}{}
\newcommand{\dsaKartenattribut}[2]{\listgadd{\dsa@attrliste}{{#1}{#2}}}

\newlength{\dsa@ax} \newlength{\dsa@ay}
\newcommand{\dsa@attrzeichne}[1]{\dsa@attrzeichneB#1}
\newcommand{\dsa@attrzeichneB}[2]{%
  \@tempcnta=\dsa@attrzaehler \divide\@tempcnta by 4\relax      % Zeile
  \@tempcntb=\dsa@attrzaehler
  \advance\@tempcntb by -\numexpr4*\@tempcnta\relax             % Spalte
  \setlength{\dsa@ax}{\dimexpr\dsakartensatzlinks
                      +\the\@tempcntb\dsakartenspaltenschritt\relax}%
  \setlength{\dsa@ay}{\dimexpr-\dsakartenrueckzeile
                      -\the\@tempcnta\dsakartenzeilenschritt\relax}%
  \node[anchor=base west, inner sep=0, outer sep=0] at (\dsa@ax,\dsa@ay)
    {\color{dsakartenschrift}\normalsize\textbf{#1}};
  \node[anchor=base west, inner sep=0, outer sep=0]
    at ($(\dsa@ax,\dsa@ay)+(\dsakartenwertversatz,0)$)
    {\color{dsakartenschrift}\normalsize #2};
  \global\advance\dsa@attrzaehler by 1\relax}

\newcommand{\dsa@attrraster}{%
  \global\dsa@attrzaehler=0\relax
  \ifdefempty{\dsa@attrliste}{%
    \global\dsa@attrunten=\dsakartenrueckzeile
  }{%
    \forlistloop{\dsa@attrzeichne}{\dsa@attrliste}%
    % Angefangene Zeilen zaehlen voll. \numexpr rundet bei der Division,
    % deshalb erst aufrunden und dann teilen.
    \@tempcnta=\numexpr(\dsa@attrzaehler+3)/4\relax
    \advance\@tempcnta by -1\relax
    \global\dsa@attrunten=\dimexpr\dsakartenrueckzeile
      +\the\@tempcnta\dsakartenzeilenschritt\relax}}

%%% ==================================================================
%%% 15  Marken am Kartenrand
%%% ==================================================================
%
% Ein Feld ist gesetzt, wenn es nach einer Expansionsstufe nicht leer ist.
% \ifstrempty allein taugt hier nicht: die Felder werden als Makro
% uebergeben (\dsa@f@medaillon), und ein Makro ist als Tokenliste nie
% leer -- die Pruefung liefe immer in den Ja-Zweig, und ein nicht gesetztes
% Medaillon endete in \includegraphics{grafiken/}.

\newcommand{\dsa@wenngesetzt}[2]{%
  \begingroup\edef\dsa@feld{#1}%
  \expandafter\endgroup\expandafter\ifstrempty\expandafter{\dsa@feld}{}{#2}}

%
% Alle drei sind an den veroeffentlichten Sets gemessen.

% --- Die Kartennummer --------------------------------------------------
%
% Weiss auf dem dunklen Rand unten rechts. Flusslande-Set, auf allen 252
% Seiten gleich: Grundlinie 241,206 bp = 85,09 mm, rechtsbuendig auf
% 170,160 bp = 60,03 mm — das ist die rechte Kante des Textrahmens
% (60,00 mm), auf drei Hundertstel genau. Grad 6 bp, fett.
%
% Das Set setzt sie weiss MIT duenner dunkler Kontur: das PDF legt neben
% den weissen Text vier Konturpfade in #231F20. Ohne die Kontur verschwaende
% die Nummer dort, wo der Rand hell ausblitzt.
\newlength{\dsakartennummeroben}   \setlength{\dsakartennummeroben}{85.09mm}
\newlength{\dsakartennummerrechts} \setlength{\dsakartennummerrechts}{60.00mm}

% Die Kontur ohne weiteres Paket: derselbe Text achtmal dunkel um ein
% Viertel bp versetzt, darueber der weisse. contour, das dsa5latex.cls
% laedt, braucht es dafuer nicht, und ein Viertel bp ist die Haarlinie,
% die das Set zeichnet.
\newlength{\dsa@konturweite} \setlength{\dsa@konturweite}{0.25bp}
\newcommand{\dsa@konturversatz}[3]{%
  \rlap{\raisebox{#2\dsa@konturweite}{%
    \hspace*{#1\dsa@konturweite}%
    \textcolor{dsakartenschrift}{#3}}}}
\newcommand{\dsa@kontur}[1]{%
  \mbox{%
    \dsa@konturversatz{-1}{-1}{#1}\dsa@konturversatz{-1}{0}{#1}%
    \dsa@konturversatz{-1}{1}{#1}\dsa@konturversatz{0}{-1}{#1}%
    \dsa@konturversatz{0}{1}{#1}\dsa@konturversatz{1}{-1}{#1}%
    \dsa@konturversatz{1}{0}{#1}\dsa@konturversatz{1}{1}{#1}%
    \textcolor{white}{#1}}}

\newcommand{\dsa@kartennummer}[1]{%
  \dsa@wenngesetzt{#1}{%
    \node[anchor=base east, inner sep=0, outer sep=0]
      at (\dsakartennummerrechts,-\dsakartennummeroben)
      {\fontsize{6bp}{6bp}\selectfont\bfseries\dsa@kontur{#1}};}}

% --- Das Portraetmedaillon ---------------------------------------------
%
% Unten links. Im Meisterpersonen-Set 20 x 20 mm mit der oberen linken Ecke
% bei (2,50 | 65,90) mm, im Flusslande-Set 14,5 x 14,5 mm buendig in der
% Ecke. Uebernommen ist das erste: es haelt Abstand zur Kartenkante, und
% den braucht eine geschnittene Karte.
\newlength{\dsakartenmedaillongroesse}
\setlength{\dsakartenmedaillongroesse}{20mm}
\newlength{\dsakartenmedaillonlinks} \setlength{\dsakartenmedaillonlinks}{2.50mm}
\newlength{\dsakartenmedaillonoben}  \setlength{\dsakartenmedaillonoben}{65.90mm}

% Das Medaillon des Sets ist kein blosses Portraet, sondern Portraet UND
% Messingkranz in einem Bild -- nachgesehen an der 237-x-237-Grafik der
% Karte AMP 01a, die beides enthaelt. Der Kranz ist derselbe, den die
% Kernklasse in ihre Wertekaesten setzt: portraitrahmen.png aus dem
% allgemeinen Baukasten, im IDML als Ornament_Portrait_Wertekasten.psd.
%
% Hier werden beide Lagen getrennt gezeichnet. Das ist der Punkt: wer eine
% Karte setzt, hat ein Portraet, keinen fertig montierten Kranz.
%
% Die Masse stammen aus dem Alphakanal von portraitrahmen.png, 418 x 413 px
% bei 300 ppi:
%
%   deckender Kranz   waagerecht Pixel  16 .. 383, also 368 von 418
%                     senkrecht  Pixel  21 .. 390, also 370 von 413
%   Kranzmitte        (199,5 | 205,5) px gegen die Dateimitte (209 | 206,5)
%   freier Innenkreis 247 px = 20,91 mm
%
% Daraus die drei Verhaeltnisse, mit denen unten gerechnet wird:
%
%   Datei / sichtbarer Kranz    418 / 368 = 1,1359
%   Versatz der Kranzmitte      -9,5 / 418 = -0,0227 der Dateibreite
%                               -1,0 / 413 = -0,0024 der Dateihoehe
%   Portraet / Datei            0,7345  (die Kernklasse setzt 26 mm Bild in
%                               eine 35,4 mm breite Ringdatei; der freie
%                               Innenkreis misst nur 21 mm, das Bild reicht
%                               also unter den Kranz und laesst keine Fuge)
\newcommand*{\dsa@kartenring}{portraitrahmen}
\newlength{\dsa@medring}   % Breite der Ringdatei
\newlength{\dsa@medbild}   % Durchmesser des Portraets
\newlength{\dsa@medmx}     % Mitte des Medaillons, waagerecht
\newlength{\dsa@medmy}     % Mitte des Medaillons, senkrecht

\newcommand{\dsa@medmasse}{%
  \setlength{\dsa@medring}{1.1359\dsakartenmedaillongroesse}%
  \setlength{\dsa@medbild}{0.7345\dsa@medring}%
  \setlength{\dsa@medmx}{\dimexpr\dsakartenmedaillonlinks
                         +0.5\dsakartenmedaillongroesse\relax}%
  \setlength{\dsa@medmy}{\dimexpr\dsakartenmedaillonoben
                         +0.5\dsakartenmedaillongroesse\relax}}

% #1 Portraet. Rund beschnitten, dann der Kranz darueber.
% Deckend einpassen statt strecken: das Bild wird an der engeren Kante auf
% das Zielmass gebracht und ragt an der anderen ueber; der \clip des
% Aufrufers schneidet es zurecht.
%
% Noetig, weil ein Portraet hochkant ist und das Medaillon rund. Mit
% width UND height an \includegraphics wird ein 896 x 1200 grosses Bild auf
% Quadrat gequetscht — am gesetzten PDF sind das 34 Prozent Stauchung in
% der Breite, und jedes Gesicht darin ist zu schmal. Dieselbe Rechnung
% macht \dsaBildDeckend in dsa5latex.cls; sie steht hier noch einmal, weil
% diese Klasse die Kernklasse nicht laedt.
\newsavebox{\dsa@messbox}
\newcommand{\dsa@deckend}[3]{%
  \sbox\dsa@messbox{\includegraphics{#3}}%
  \pgfmathsetmacro{\dsa@bildverh}{\wd\dsa@messbox/\ht\dsa@messbox}%
  \pgfmathsetmacro{\dsa@zielverh}{(#1)/(#2)}%
  \ifdim\dsa@bildverh pt>\dsa@zielverh pt
    \includegraphics[height=#2]{#3}%
  \else
    \includegraphics[width=#1]{#3}%
  \fi}

% Zerlegt „anteil,x,y" und reicht die drei Zahlen weiter.
\newcommand{\dsa@ausschnittdrei}[3]{\dsa@ausschnittdreiB{#1}#2\relax{#3}}
\def\dsa@ausschnittdreiB#1#2,#3,#4\relax#5{\dsa@ausschnitt{#1}{#2}{#3}{#4}{#5}}

% --- Der Bildausschnitt des Medaillons ---------------------------------
%
% \dsa@deckend allein genuegt nicht. Es passt das Bild deckend ein und
% zeigt dessen MITTE — bei einer Dreiviertelfigur ist das der Bauch, und
% der Kopf steht ueber dem Kreis. Am gesetzten Kartensatz war das an sechs
% von acht Medaillons zu sehen.
%
% Automatisch loesen laesst es sich nicht verlaesslich: ein Versuch, den
% Kopf ueber die Silhouette zu finden (oberste Figurzeile, Kopfbreite in
% der oberen Zone, Schulterlinie am Breitensprung), traf bei schmalkoepfigen
% Figuren gut und scheiterte an Haaren, Baerten, getragenen Dingen und an
% einer Gans mit ausgebreiteten Fluegeln. Die Kopfbreite wurde dort um das
% Zwei- bis Dreifache zu gross gemessen.
%
% Deshalb wird der Ausschnitt angegeben, nicht geraten. Drei Zahlen:
%
%   anteil  Kantenlaenge des sichtbaren Quadrats, als Anteil der KUERZEREN
%           Bildseite. 1 ist der deckende Ausschnitt und die Vorgabe,
%           kleinere Werte zoomen hinein.
%   x, y    wo die Mitte dieses Quadrats im Bild liegt, als Anteil der
%           Bildbreite und -hoehe. 0,5/0,5 ist die Bildmitte.
%
%   \dsaKartenmedaillon[0.59,0.5,0.24]{portraet}
%
% Abgelesen wird das am Bild: Kopfbreite und Augenhoehe in Pixeln, geteilt
% durch die Bildmasse. Das ist die Arbeit, die im Original schon getan ist —
% dort liegt das Medaillon als fertig zugeschnittenes Brustbild bei, und
% dafuer gibt es \dsaKartenmedaillonfertig.
\newlength{\dsa@ausx} \newlength{\dsa@ausy}
\newlength{\dsa@ausbreite} \newlength{\dsa@aushoehe}

% #1 Zielgroesse, #2 anteil, #3 x, #4 y, #5 Bild
%
% Gerechnet wird in zwei Schritten, und die Reihenfolge ist noetig:
% pgfmath liefert reine Zahlen (in pt gerechnet), \setlength braucht einen
% Faktor VOR einer Laenge. Ein geklammerter Ausdruck als Faktor, etwa
% \dimexpr(0.5-0.24)\dsa@aushoehe, ist kein gueltiger \dimexpr — deshalb
% wird der Faktor erst als Zahl ausgerechnet und dann angewandt.
\newcommand{\dsa@ausschnitt}[5]{%
  \sbox\dsa@messbox{\includegraphics{#5}}%
  % Die kuerzere Bildseite bestimmt den Massstab: das sichtbare Quadrat
  % soll #2 davon breit sein und auf die Zielgroesse kommen.
  \pgfmathsetmacro{\dsa@mass}{%
    (#1)/((#2)*min(\wd\dsa@messbox,\ht\dsa@messbox))}%
  \setlength{\dsa@ausbreite}{\dsa@mass\wd\dsa@messbox}%
  \setlength{\dsa@aushoehe}{\dsa@mass\ht\dsa@messbox}%
  % Wohin der gewuenschte Punkt gegen die Bildmitte rueckt.
  \pgfmathsetmacro{\dsa@fx}{0.5-(#3)}%
  \pgfmathsetmacro{\dsa@fy}{0.5-(#4)}%
  \setlength{\dsa@ausx}{\dsa@fx\dsa@ausbreite}%
  \setlength{\dsa@ausy}{\dsa@fy\dsa@aushoehe}%
  \node[anchor=center, inner sep=0, outer sep=0]
    at ($(\dsa@medmx,-\dsa@medmy)+(\dsa@ausx,-\dsa@ausy)$)
    {\includegraphics[width=\dsa@ausbreite]{#5}};}

% #1 optional: anteil,x,y — #2 Bild
\newcommand{\dsa@medaillon}[2][1,0.5,0.5]{%
  \dsa@wenngesetzt{#2}{%
    \dsa@medmasse
    \begin{scope}
      \clip (\dsa@medmx,-\dsa@medmy) circle (0.5\dsa@medbild);
      \dsa@ausschnittdrei{\dsa@medbild}{#1}{\dsagrafik{#2}}%
    \end{scope}
    % Die Ringdatei sitzt um den Versatz nach rechts und unten, damit der
    % KRANZ mittig liegt und nicht die Datei.
    \node[anchor=center, inner sep=0, outer sep=0]
      at ($(\dsa@medmx,-\dsa@medmy)+(0.0227\dsa@medring,-0.0024\dsa@medring)$)
      {\includegraphics[width=\dsa@medring]{\dsagrafik{\dsa@kartenring}}};}}

% Ein fertig montiertes Medaillon -- Portraet und Kranz schon in einem Bild,
% wie das Set es liefert. Dann zeichnet die Klasse keinen zweiten Kranz.
\newcommand{\dsa@medaillonfertig}[1]{%
  \dsa@wenngesetzt{#1}{%
    \dsa@medmasse
    \begin{scope}
      \clip (\dsa@medmx,-\dsa@medmy)
            circle (0.5\dsakartenmedaillongroesse);
      \node[anchor=center, inner sep=0, outer sep=0]
        at (\dsa@medmx,-\dsa@medmy)
        {\dsa@deckend{\dsakartenmedaillongroesse}%
                     {\dsakartenmedaillongroesse}{\dsagrafik{#1}}};
    \end{scope}}}
% Deckend eingepasst, nicht gestreckt. Ein Portraet fuer diese Stelle darf
% Stelle wird ohnehin quadratisch zugeschnitten, und
% werkzeuge/freistellen.py kann das mit --x und --y.

% --- Der Illustrationsnachweis -----------------------------------------
%
% Meisterpersonen-Set: 5,5 bp auf 6,6 bp, rechte Kante 154,777 bp =
% 54,60 mm, letzte Grundlinie 209,608 bp = 73,95 mm. Zwei Zeilen, die
% zweite kursiv.
\newlength{\dsakartennachweisrechts} \setlength{\dsakartennachweisrechts}{54.60mm}
\newlength{\dsakartennachweisoben}   \setlength{\dsakartennachweisoben}{73.95mm}
\newcommand{\dsa@nachweis}[1]{%
  \dsa@wenngesetzt{#1}{%
    \node[anchor=base east, inner sep=0, outer sep=0, align=right]
      at (\dsakartennachweisrechts,-\dsakartennachweisoben)
      {\color{dsakartenschrift}\fontsize{5.5bp}{6.6bp}\selectfont
       Illustration:\\\itshape #1};}}

% --- Das Kartenbild der Vorderseite ------------------------------------
%
% Der Baukasten sagt dazu nichts: sein Bildrahmen ist die Kartenflaeche
% selbst, eine Figur ist darin nicht vorgesehen. Beide Sets setzen sie von
% Hand — im Meisterpersonen-Set liegen die 53 Bildrahmen waagerecht
% zwischen 6,49 und 166,3 bp und senkrecht zwischen 35,67 und 249,45 bp.
% Einen gemeinsamen Rahmen zum Nachmessen gibt es also nicht.
%
% OFFEN: Das Bildfeld ist deshalb gesetzt, nicht gemessen — aber nur an
% drei seiner vier Kanten. Links und rechts steht es auf dem Textrahmen,
% unten auf 82 mm, eine Zeile ueber der Kartennummer (85,09 mm).
%
% Die Oberkante wird gerechnet, nicht gesetzt: sie ist die Unterkante des
% Kartenkopfs. Ein fester Wert ginge hier nicht, weil der Kopf ein-, zwei-
% oder dreizeilig sein kann — bei „Albenhuser Rossschinder" sind es zwei
% Zeilen, und ein auf die einzeilige Fassung gesetztes Bildfeld deckte den
% Untertitel „WAFFE" zu. Gemessen wird die Tiefe der Kopfbox, und die
% enthaelt den Abstand nach dem Untertitel (SpaceAfter 2,20 mm) schon.
\newlength{\dsakartenbildlinks}  \setlength{\dsakartenbildlinks}{3mm}
\newlength{\dsakartenbildbreite} \setlength{\dsakartenbildbreite}{57mm}
\newlength{\dsakartenbildunten}  \setlength{\dsakartenbildunten}{82mm}

\newlength{\dsa@bildoben}
\newlength{\dsa@bildhoehe}

% Einpassend, nicht deckend: eine freigestellte Figur darf nicht
% angeschnitten werden. keepaspectratio waehlt selbst die engere Kante.
%
% #1 Grafik, #2 Oberkante des Bildfelds
\newcommand{\dsa@kartenbild}[2]{%
  \dsa@kartenbildbis{#1}{#2}{\dsakartenbildunten}}

% Wie \dsa@kartenbild, aber mit eigener Unterkante — der
% Verbrauchsgegenstand setzt seinen Text darunter und braucht das Feld
% deshalb kuerzer.
%
% #1 Grafik, #2 Oberkante, #3 Unterkante
\newcommand{\dsa@kartenbildbis}[3]{%
  \dsa@wenngesetzt{#1}{%
    \setlength{\dsa@bildoben}{#2}%
    \setlength{\dsa@bildhoehe}{\dimexpr#3-\dsa@bildoben\relax}%
    \node[anchor=north, inner sep=0, outer sep=0]
      at ($(\dsakartenbildlinks,-\dsa@bildoben)
           +(0.5\dsakartenbildbreite,0)$)
      {\includegraphics[width=\dsakartenbildbreite,
                        height=\dsa@bildhoehe,
                        keepaspectratio]{\dsagrafik{#1}}};}}

%%% ==================================================================
%%% 16  Karten sammeln und ausgeben
%%% ==================================================================
%
% Jede Karte wird bei ihrer Deklaration in zwei Boxen gesetzt, Vorder- und
% Rueckseite. Danach haengt es nur noch an der Druckfassung, wohin die
% Boxen kommen:
%
%   einzeln   sofort je eine Seite. Kein Sammeln noetig.
%   bogen     gesammelt, und je neun Karten ein Bogenpaar.
%
% Sofort setzen statt den Quelltext zu merken hat einen handfesten Grund:
% was einmal in einer Box steht, laesst sich beliebig oft und an beliebiger
% Stelle wieder aufs Blatt legen — auf der Rueckseite eines Bogens genauso
% wie auf der Vorderseite, und ohne dass der Inhalt ein zweites Mal durch
% den Umbruch muss.

\newcount\dsa@kartenzahl  \dsa@kartenzahl=0
\newcount\dsa@bogenplatz  \dsa@bogenplatz=0
\newcount\dsa@lauf

% Neun Karten je Bogen, also 18 Boxen: 3 x 3 Karten zu 63 x 88 mm sind
% 189 x 264 mm und passen auf A4.
\dsa@lauf=0
\loop\ifnum\dsa@lauf<18\relax
  \expandafter\newsavebox\csname dsa@kbox\number\dsa@lauf\endcsname
  \advance\dsa@lauf by 1
\repeat
\newcommand{\dsa@kbox}[1]{\csname dsa@kbox\number\numexpr#1\relax\endcsname}

% --- Der Bogen ---------------------------------------------------------
%
% 3 Spalten, 3 Zeilen, mittig auf A4:
%   waagerecht (210 - 3*63)/2 = 10,5 mm
%   senkrecht  (297 - 3*88)/2 = 16,5 mm
\newlength{\dsabogenrandx} \setlength{\dsabogenrandx}{10.5mm}
\newlength{\dsabogenrandy} \setlength{\dsabogenrandy}{16.5mm}

% Vorder- und Rueckseite eines Bogens muessen beim beidseitigen Druck
% aufeinanderpassen. Beim Wenden an der langen Kante — der Normalfall bei
% Hochkant-Duplex — dreht sich das Blatt um die senkrechte Mittelachse:
% Spalte 1 liegt physisch dort, wo vorne Spalte 3 lag. Fuer jede Karte gilt
% deshalb
%
%   Spalte' = 2 - Spalte        (Zeile bleibt gleich, gezaehlt ab 0)
%
% Mit Option „kurz" wird an der kurzen Kante gewendet, dann statt dessen
% Zeile' = 2 - Zeile. Dieselbe Ueberlegung wie in dsa5aufsteller.sty, hier
% aber auf einem festen Raster und darum als Spaltentausch schreibbar.
\newlength{\dsa@bx} \newlength{\dsa@by}
\newcommand{\dsa@bogenstelle}[2]{%
  % #1 Platz 0..8, #2 true = Rueckseite
  \@tempcnta=#1\relax \divide\@tempcnta by 3\relax        % Zeile 0..2
  \@tempcntb=#1\relax
  \advance\@tempcntb by -\numexpr3*\@tempcnta\relax       % Spalte 0..2
  \if#2t%
    \ifdsa@kurz \@tempcnta=\numexpr2-\@tempcnta\relax
    \else       \@tempcntb=\numexpr2-\@tempcntb\relax \fi
  \fi
  \setlength{\dsa@bx}{\dimexpr\dsabogenrandx
                      +\the\@tempcntb\dsakartenbreite\relax}%
  \setlength{\dsa@by}{\dimexpr\dsabogenrandy
                      +\the\@tempcnta\dsakartenhoehe\relax}}

% Schnittmarken: kurze Striche ausserhalb des Kartenfelds, an jeder
% Trennlinie. Nur am Bogenrand — zwischen den Karten stossen die Kanten
% ohne Zwischenraum aneinander, dort waere die Marke im Bild.
\newlength{\dsa@mk}
% Gezeichnet werden nur die Marken der belegten Zeilen. Auf dem letzten
% Bogen eines Satzes bleiben Plaetze frei — Marken fuer eine leere Zeile
% wiesen dort auf einen Schnitt, den es nicht zu tun gibt.
\newcount\dsa@bogenzeilen
\newlength{\dsa@mkunten}
\newcommand{\dsa@schnittmarken}{%
  \ifdsa@schnittmarken
    % Angefangene Zeilen zaehlen voll: \numexpr rundet bei der Division,
    % deshalb vorher zwei addieren und erst dann teilen.
    \dsa@bogenzeilen=\numexpr(\dsa@bogenplatz+2)/3\relax
    \setlength{\dsa@mkunten}{\dimexpr\dsabogenrandy
                             +\the\dsa@bogenzeilen\dsakartenhoehe\relax}%
    \foreach \dsa@i in {0,1,2,3}{%
      \setlength{\dsa@mk}{\dimexpr\dsabogenrandx
                          +\dsa@i\dsakartenbreite\relax}%
      \draw[line width=0.25bp, black]
        (\dsa@mk,-\dimexpr\dsabogenrandy-4mm\relax)
        -- (\dsa@mk,-\dimexpr\dsabogenrandy-1mm\relax);
      \draw[line width=0.25bp, black]
        (\dsa@mk,-\dimexpr\dsa@mkunten+1mm\relax)
        -- (\dsa@mk,-\dimexpr\dsa@mkunten+4mm\relax);}%
    \dsa@lauf=0
    \loop\ifnum\dsa@lauf<\numexpr\dsa@bogenzeilen+1\relax
      \setlength{\dsa@mk}{\dimexpr\dsabogenrandy
                          +\the\dsa@lauf\dsakartenhoehe\relax}%
      \draw[line width=0.25bp, black]
        (\dimexpr\dsabogenrandx-4mm\relax,-\dsa@mk)
        -- (\dimexpr\dsabogenrandx-1mm\relax,-\dsa@mk);
      \draw[line width=0.25bp, black]
        (\dimexpr\dsabogenrandx+3\dsakartenbreite+1mm\relax,-\dsa@mk)
        -- (\dimexpr\dsabogenrandx+3\dsakartenbreite+4mm\relax,-\dsa@mk);
      \advance\dsa@lauf by 1
    \repeat
  \fi}

\newcommand{\dsa@bogenseite}[1]{%
  % #1: v = Vorderseiten, r = Rueckseiten
  \noindent
  \begin{tikzpicture}
    \useasboundingbox (0,0) rectangle (\dsa@seitenbreite,-\dsa@seitenhoehe);
    \dsa@lauf=0
    \loop\ifnum\dsa@lauf<\dsa@bogenplatz\relax
      \if#1v%
        \dsa@bogenstelle{\dsa@lauf}{f}%
        \node[anchor=north west, inner sep=0, outer sep=0] at (\dsa@bx,-\dsa@by)
          {\usebox{\dsa@kbox{2*\dsa@lauf}}};
      \else
        \dsa@bogenstelle{\dsa@lauf}{t}%
        \node[anchor=north west, inner sep=0, outer sep=0] at (\dsa@bx,-\dsa@by)
          {\usebox{\dsa@kbox{2*\dsa@lauf+1}}};
      \fi
      \advance\dsa@lauf by 1
    \repeat
    \dsa@schnittmarken
  \end{tikzpicture}%
  \clearpage}

\newcommand{\dsa@bogenausgeben}{%
  \ifnum\dsa@bogenplatz>0\relax
    \dsa@bogenseite{v}%
    \dsa@bogenseite{r}%
    \global\dsa@bogenplatz=0\relax
  \fi}

% --- Eine fertige Karte abliefern --------------------------------------
%
% Bei „einzeln" sitzt die Karte in der oberen linken Blattecke; mit
% „anschnitt" ist das Blatt 3 mm groesser, und sie rueckt um den Anschnitt
% nach innen, damit die Flaechengrafik bis an die Blattkante reicht.
\newcommand{\dsa@einzelseite}[1]{%
  \noindent
  \begin{tikzpicture}
    \useasboundingbox (0,0) rectangle (\dsa@seitenbreite,-\dsa@seitenhoehe);
    \ifdsa@anschnitt
      \node[anchor=north west, inner sep=0, outer sep=0]
        at (\dsakartenanschnittx,-\dsakartenanschnitty) {#1};
    \else
      \node[anchor=north west, inner sep=0, outer sep=0] at (0,0) {#1};
    \fi
  \end{tikzpicture}%
  \clearpage}

% Wie oft die Karte auf den Bogen soll. Zehn Heiltraenke sind zehn Karten,
% aber nur ein Eintrag im Quelltext.
%
% Die Zahl gilt NUR fuer den Bogen. Bei „einzeln" bleibt es bei einer
% Seite je Kartenseite: das ist die Druckvorlage, und die Auflage
% vereinbart man mit der Druckerei, nicht im Dokument.
\newcount\dsa@f@anzahl \dsa@f@anzahl=1
\newcommand{\dsaKartenanzahl}[1]{\global\dsa@f@anzahl=#1\relax}

% Zwei Zwischenboxen: die Karte wird EINMAL gesetzt und danach nur noch
% kopiert. Sonst liefe der ganze Satz je Stueck erneut durch den Umbruch —
% bei zehn Heiltraenken zehnmal fuer dasselbe Ergebnis.
\newsavebox{\dsa@vorlagevorn}
\newsavebox{\dsa@vorlagehint}

\newcommand{\dsa@karteabliefern}[2]{%
  \ifdsa@bogen
    \sbox{\dsa@vorlagevorn}{#1}%
    \sbox{\dsa@vorlagehint}{#2}%
    \dsa@lauf=0
    \loop\ifnum\dsa@lauf<\dsa@f@anzahl\relax
      \global\advance\dsa@kartenzahl by 1\relax
      \global\setbox\dsa@kbox{2*\dsa@bogenplatz}=\copy\dsa@vorlagevorn
      \global\setbox\dsa@kbox{2*\dsa@bogenplatz+1}=\copy\dsa@vorlagehint
      \global\advance\dsa@bogenplatz by 1\relax
      \ifnum\dsa@bogenplatz=9\relax \dsa@bogenausgeben \fi
      \advance\dsa@lauf by 1
    \repeat
  \else
    \global\advance\dsa@kartenzahl by 1\relax
    \dsa@einzelseite{#1}%
    \dsa@einzelseite{#2}%
  \fi
  \global\dsa@f@anzahl=1\relax}

% Den angefangenen Bogen am Ende noch ausgeben.
\AtEndDocument{\ifdsa@bogen\dsa@bogenausgeben\fi}

%%% ==================================================================
%%% 17  Die Kartentypen
%%% ==================================================================
%
% Fuenf Typen, jeder eine Umgebung mit Setzbefehlen darin. Warum Umgebung
% und nicht ein Befehl mit acht Argumenten: eine NSC-Karte hat acht Felder,
% und acht Argumente in Reihe sind im Quelltext nicht mehr zu lesen — man
% zaehlt Klammern statt Felder. Die Setzbefehle nennen jedes Feld beim
% Namen und duerfen in beliebiger Reihenfolge stehen.

% --- Die Felder --------------------------------------------------------
\newcommand{\dsa@f@name}{}
\newcommand{\dsa@f@untertitel}{}
\newcommand{\dsa@f@bild}{}
\newcommand{\dsa@f@nummer}{}
\newcommand{\dsa@f@medaillon}{}
\newcommand{\dsa@f@nachweis}{}
\newcommand{\dsa@f@rueck}{}

\newcommand{\dsaKartenname}[1]{\renewcommand{\dsa@f@name}{#1}}
\newcommand{\dsaKartenuntertitel}[1]{\renewcommand{\dsa@f@untertitel}{#1}}
\newcommand{\dsaKartenbild}[1]{\renewcommand{\dsa@f@bild}{#1}}
\newcommand{\dsaKartennummer}[1]{\renewcommand{\dsa@f@nummer}{#1}}
\newcommand{\dsa@f@ausschnitt}{1,0.5,0.5}
\newcommand{\dsaKartenmedaillon}[2][1,0.5,0.5]{%
  \renewcommand{\dsa@f@medaillon}{#2}%
  \renewcommand{\dsa@f@ausschnitt}{#1}%
  \dsa@medfertigfalse}
% Fuer ein Bild, das den Kranz schon mitbringt.
\newif\ifdsa@medfertig \dsa@medfertigfalse
\newcommand{\dsaKartenmedaillonfertig}[1]{%
  \renewcommand{\dsa@f@medaillon}{#1}\dsa@medfertigtrue}
\newcommand{\dsaKartennachweis}[1]{\renewcommand{\dsa@f@nachweis}{#1}}

% Der Rueckseitentext wird gesammelt statt sofort gesetzt: beim Lesen der
% Umgebung steht noch nicht fest, was vor ihm kommt — bei Waffe und
% Ruestung die Wertetabelle, beim Monster das Attributraster.
% \gappto aus etoolbox haengt an, ohne zu expandieren, und ist \long,
% vertraegt also Absaetze im Kartentext.
% Ab \dsaKartenfortsetzung landet alles Weitere in einem zweiten Fluss.
% Gebraucht wird der nur von den drei Textkarten (Zauber, Sonderfertigkeit,
% Kultur): sie tragen bei den Sets auf BEIDEN Seiten denselben Text, und
% erst wenn er nicht auf eine Seite passt, laeuft er auf der Rueckseite
% weiter. Von 126 Flusslande-Karten sind 39 beidseitig gleich — genau die,
% deren Text auf eine Seite ging.
\newif\ifdsa@fortsetzung \dsa@fortsetzungfalse
\newcommand{\dsa@f@fort}{}
\newcommand{\dsaKartenfortsetzung}{\dsa@fortsetzungtrue}

\newcommand{\dsa@flussanfuegen}[1]{%
  \ifdsa@fortsetzung \gappto\dsa@f@fort{#1}%
  \else              \gappto\dsa@f@rueck{#1}\fi}

\newcommand{\dsaKartentext}[1]{\dsa@flussanfuegen{\dsaKartenabsatz{#1}}}
\newcommand{\dsaKartenstich}[2]{\dsa@flussanfuegen{\dsaKarteStich{#1}{#2}}}

% Beschriftung UEBER dem Wert statt davor, dazwischen kein Absatzabstand,
% danach eine Leerzeile. So setzt das Flusslande-Set seine Impressumskarte
% (H 001): „Verlagsleitung" fett auf 16,21 mm, der Name darunter auf
% 18,96 mm — 2,75 mm, also ein Zeilenschritt —, und die naechste
% Beschriftung erst auf 24,46 mm, also zwei Zeilenschritte weiter.
%
% Fuer den Stichwortabsatz mit haengendem Einzug gibt es \dsaKartenstich;
% die beiden sind nicht dasselbe und sehen auch nicht so aus.
\newcommand{\dsaKartenzeile}[2]{\dsa@flussanfuegen{\dsaKarteZeile{#1}{#2}}}

\newcommand{\dsaKarteZeile}[2]{%
  \dsa@absatzluft
  {\textbf{#1}\par\nobreak #2\par}}

\newcommand{\dsa@felderleeren}{%
  \renewcommand{\dsa@f@name}{}%
  \renewcommand{\dsa@f@untertitel}{}%
  \renewcommand{\dsa@f@bild}{}%
  \renewcommand{\dsa@f@nummer}{}%
  \renewcommand{\dsa@f@medaillon}{}%
  \renewcommand{\dsa@f@nachweis}{}%
  \renewcommand{\dsa@f@rueck}{}%
  \renewcommand{\dsa@werteliste}{}%
  \renewcommand{\dsa@wertekopf}{}%
  \renewcommand{\dsa@attrliste}{}%
  \renewcommand{\dsa@f@fort}{}%
  \dsa@fortsetzungfalse
  \dsa@medfertigfalse
  \renewcommand{\dsa@f@ausschnitt}{1,0.5,0.5}%
  \global\dsa@ersterabsatztrue}


% Welche der beiden Fassungen gilt, entscheidet das Feld.
\newcommand{\dsa@medaillonwahl}{%
  \ifdsa@medfertig \dsa@medaillonfertig{\dsa@f@medaillon}%
  \else
    \expandafter\dsa@medaillon\expandafter[\dsa@f@ausschnitt]%
      {\dsa@f@medaillon}%
  \fi}

% --- Die Vorderseite ---------------------------------------------------
%
% Bei allen fuenf Typen dieselbe: Flaeche, Bild, Name, Untertitel, Nummer.
% Sie unterscheiden sich nur im Untertitel — beim NSC ist er die
% Kurzbezeichnung, sonst die Gattung („WAFFE", „GEGENSTAND", …), wie beide
% Sets es zeigen.
% Der Kopf wird zuerst in eine Box gesetzt, damit seine Tiefe bekannt ist,
% bevor das Bild platziert wird: die Oberkante des Bildfelds ist die
% Unterkante des Kopfs (siehe \dsa@kartenbild). Gezeichnet wird die Box
% danach an ihrer ersten Grundlinie — \vtop liefert genau die als
% Bezugspunkt, die Tiefe ist also der Rest des Kopfs.
\newsavebox{\dsa@kopfbox}
\newcommand{\dsa@vorderseite}{%
  \global\dsa@ersterabsatztrue
  \sbox{\dsa@kopfbox}{%
    \vtop{\hsize=\dsakartensatzbreite
          \parindent=0pt \parskip=0pt
          \normalsize
          \dsaKartenkopf{\dsa@f@name}{\dsa@f@untertitel}}}%
  \dsa@kartenblatt{%
    \dsa@kartenbild{\dsa@f@bild}%
      {\dimexpr\dsakartenerstezeile+\dp\dsa@kopfbox\relax}%
    \node[anchor=base west, inner sep=0, outer sep=0,
          text=dsakartenschrift]
      at (\dsakartensatzlinks,-\dsakartenerstezeile)
      {\usebox{\dsa@kopfbox}};
    \dsa@kartennummer{\dsa@f@nummer}}}

% --- NSC ---------------------------------------------------------------
%
% Vorbild: „Aventurische Meisterpersonen". Vorne Figur, Name,
% Kurzbezeichnung; hinten Kurzcharakteristik, Hintergrund, Stichwoerter,
% Medaillon, Illustrationsnachweis.
\newenvironment{dsaKarteNSC}{%
  \dsa@felderleeren\ignorespaces}{%
  \dsa@karteabliefern
    {\dsa@vorderseite}%
    {\dsa@kartenblatt{%
       \global\dsa@ersterabsatztrue
       \dsa@kartenfluss{\dsakartenrueckzeile}{\dsa@f@rueck}%
       \dsa@medaillonwahl%
       \dsa@nachweis{\dsa@f@nachweis}%
       \dsa@kartennummer{\dsa@f@nummer}}}}

% --- Gegenstand --------------------------------------------------------
%
% Vorbild: „Flusslande". Vorne der Gegenstand freigestellt, Name, „GEGEN-
% STAND"; hinten nur Stichwortabsaetze — Beschreibung, Wirkung, Kosten,
% Preis. Keine Tabelle: gemessen an H 033 beginnt der Satz direkt auf der
% ersten Rueckseitengrundlinie.
\newcommand{\dsa@textkarte}{%
  \dsa@karteabliefern
    {\dsa@vorderseite}%
    {\dsa@kartenblatt{%
       \global\dsa@ersterabsatztrue
       \dsa@kartenfluss{\dsakartenrueckzeile}{\dsa@f@rueck}%
       \dsa@medaillonwahl%
       \dsa@kartennummer{\dsa@f@nummer}}}}

\newenvironment{dsaKarteGegenstand}{%
  \dsa@felderleeren
  \dsaKartenuntertitel{Gegenstand}\ignorespaces}{%
  \dsa@textkarte}

% --- Waffe und Ruestung ------------------------------------------------
%
% Vorbild: „Flusslande". Vorne der Gegenstand freigestellt, Name, Gattung;
% hinten die Wertetabelle und darunter Vorteil und Nachteil als
% Stichwortabsaetze.
%
% Beide Typen haben dieselbe Bauform und nur andere Zeilen in der Tabelle.
% Deshalb eine gemeinsame innere Fassung und zwei Umgebungen, die den
% Untertitel vorbelegen.
\newcommand{\dsa@wertekarte}{%
  \dsa@karteabliefern
    {\dsa@vorderseite}%
    {\dsa@kartenblatt{%
       \dsa@wertetabelle
       % Der Text beginnt eine Tabellenzeile unter der Tabelle. Gemessen
       % im Flusslande-Set: Tabellenunterkante 150,804 bp, erste Textzeile
       % 162,402 bp — 11,6 bp, also eine Zeilenhoehe.
       \global\dsa@ersterabsatztrue
       \dsa@kartenfluss{\dimexpr\dsa@wertunten
                        +\dsakartenzeilenhoehe\relax}{\dsa@f@rueck}%
       \dsa@kartennummer{\dsa@f@nummer}}}}

\newenvironment{dsaKarteWaffe}{%
  \dsa@felderleeren
  \dsaKartenuntertitel{Waffe}\ignorespaces}{%
  \dsaKartenwertkopf{\dsa@f@name}%
  \dsa@wertekarte}

\newenvironment{dsaKarteRuestung}{%
  \dsa@felderleeren
  \dsaKartenuntertitel{R\"ustung}\ignorespaces}{%
  \dsaKartenwertkopf{\dsa@f@name}%
  \dsa@wertekarte}

% --- Monster -----------------------------------------------------------
%
% Vorbild: „Flusslande", die Kreaturenkarten. Vorne die Kreatur
% freigestellt, Name, Gattung — die steht dort ausgeschrieben
% („KREATUR, NICHT HUMANOID", „TIER, NICHT HUMANOID", „DRACHE, NICHT
% HUMANOID"), deshalb ist der Untertitel hier nicht vorbelegt, sondern
% wird gesetzt. Hinten das Attributraster und darunter die Stichwoerter,
% dazu das Medaillon.
\newenvironment{dsaKarteMonster}{%
  \dsa@felderleeren
  \dsaKartenuntertitel{Kreatur, nicht humanoid}\ignorespaces}{%
  \dsa@karteabliefern
    {\dsa@vorderseite}%
    {\dsa@kartenblatt{%
       \dsa@attrraster
       % Der Text beginnt eine Zeile unter der letzten Rasterzeile.
       % Gemessen an H 101: letzte Rasterzeile 80,924 bp, erste Textzeile
       % 88,724 bp — 7,8 bp, also genau ein Zeilenschritt.
       \global\dsa@ersterabsatztrue
       \dsa@kartenfluss{\dimexpr\dsa@attrunten
                        +\dsakartenzeilenschritt\relax}{\dsa@f@rueck}%
       \dsa@medaillonwahl%
       \dsa@kartennummer{\dsa@f@nummer}}}}

% --- Textkarten: Zauber, Sonderfertigkeit, Kultur ----------------------
%
% Vorbild: „Flusslande". Diese drei haben keine Abbildung. Kopf und Text
% stehen in EINEM Fluss — der Abstand dazwischen kommt aus dem Baukasten
% selbst, aus dem SpaceAfter des Untertitels (6,23622 bp). Am Set
% nachgerechnet: die erste Textzeile sitzt 14,036 bp unter dem Untertitel,
% und das sind 7,8 bp Durchschuss plus eben jene 6,236 bp. Bei der einen
% Karte mit 7-bp-Satz sind es 14,637 bp — 8,4 plus 6,237. Es braucht hier
% also kein eigenes Mass, der Kopf bringt seinen Abstand mit.
\newcommand{\dsa@kopftextseite}[1]{%
  \dsa@kartenblatt{%
    \global\dsa@ersterabsatztrue
    \dsa@kartenfluss{\dsakartenerstezeile}{%
      \dsaKartenkopf{\dsa@f@name}{\dsa@f@untertitel}#1}%
    \dsa@kartennummer{\dsa@f@nummer}}}

% Die Rueckseite einer Textkarte: ohne \dsaKartenfortsetzung eine Kopie der
% Vorderseite, sonst die Fortsetzung allein — ohne Kopf, beginnend auf der
% ersten Rueckseitengrundlinie. Beides ist am Set abgelesen: H 067 traegt
% beidseitig dasselbe, H 053 vorne Beschreibung und Probe, hinten
% Reichweite, Wirkungsdauer und den Rest.
\newcommand{\dsa@textkartehinten}{%
  \ifdefempty{\dsa@f@fort}%
    {\dsa@kopftextseite{\dsa@f@rueck}}%
    {\dsa@kartenblatt{%
       \global\dsa@ersterabsatztrue
       \dsa@kartenfluss{\dsakartenrueckzeile}{\dsa@f@fort}%
       \dsa@kartennummer{\dsa@f@nummer}}}}

\newcommand{\dsa@textkartesetzen}{%
  \dsa@karteabliefern
    {\dsa@kopftextseite{\dsa@f@rueck}}%
    {\dsa@textkartehinten}}

% Die Gattung steht bei allen dreien auf der Karte und wechselt innerhalb
% des Typs — „ZAUBERSPRUCH", „ZAUBERTRICK", „RITUAL", „LITURGIE",
% „ZEREMONIE", „DOLCHRITUAL" sind im Flusslande-Set alle derselbe Aufbau.
% Deshalb ist der Untertitel hier nur vorbelegt, nicht festgelegt.
\newenvironment{dsaKarteZauber}{%
  \dsa@felderleeren
  \dsaKartenuntertitel{Zauberspruch}\ignorespaces}{%
  \dsa@textkartesetzen}

\newenvironment{dsaKarteSonderfertigkeit}{%
  \dsa@felderleeren
  \dsaKartenuntertitel{Sonderfertigkeit}\ignorespaces}{%
  \dsa@textkartesetzen}

% Kultur- und Professionskarten. Der Name traegt die Stufe mit
% („Ferdoker Land (Stufe II)"), der Untertitel nennt die Art des Eintrags.
\newenvironment{dsaKarteKultur}{%
  \dsa@felderleeren
  \dsaKartenuntertitel{Wesenszug}\ignorespaces}{%
  \dsa@textkartesetzen}

%%% ==================================================================
%%% 18  Der generische Kartenruecken
%%% ==================================================================
%
% Einseitige Karten -- Verbrauchsgegenstaende etwa -- brauchen trotzdem
% eine Rueckseite, sonst kommt aus dem Duplexdruck ein leeres Blatt.
%
% Der Spielkarten-Baukasten liefert dafuer nichts: er kennt nur die eine
% Kartenflaeche, und die ist beidseitig dieselbe. Die gedruckten Sets haben
% einen gemeinsamen Ruecken, aber der steckt in keinem der beiden PDF --
% dort stehen nur die Karteninhalte.
%
% Drei Motive kommen deshalb aus dem allgemeinen Layout-Baukasten, aus
% Grafiken, die werkzeuge/aufbereiten.py ohnehin anlegt:
%
%   \dsaRueckenRaute       die Rautenkachel gross in der Kartenmitte.
%                          Vorgabe. Die Kachel ist 215 x 259 px = 18,2 x
%                          21,9 mm; hier auf 34 mm Hoehe gebracht.
%   \dsaRueckenRautenfeld  dieselbe Kachel ueber die ganze Flaeche
%                          gerastert -- die klassische Machart eines
%                          Spielkartenruckens.
%   \dsaRueckenZierleiste  ornament-mittig senkrecht in der Kartenmitte.
%                          Die Leiste ist 206 x 964 px = 17,4 x 81,6 mm
%                          und damit fast so hoch wie die Karte.
%
% Umgestellt wird mit \dsaKartenruecken{...}; ein leeres Argument laesst
% die blanke Kartenflaeche stehen.
%
% Die Rautenkachel gibt es in drei Farben (grau, gruen, rot). Welche gilt,
% sagt \dsaKartenraute.
\newcommand*{\dsa@rautenbild}{raute-grau}
\newcommand*{\dsaKartenraute}[1]{\renewcommand*{\dsa@rautenbild}{#1}}

\newlength{\dsakartenrautenhoehe} \setlength{\dsakartenrautenhoehe}{34mm}
\newcommand{\dsaRueckenRaute}{%
  \node[anchor=center, inner sep=0, outer sep=0]
    at (0.5\dsakartenbreite,-0.5\dsakartenhoehe)
    {\includegraphics[height=\dsakartenrautenhoehe]{\dsagrafik{\dsa@rautenbild}}};}

% Das Feld: die Kachel gerastert, jede zweite Zeile um eine halbe Spalte
% versetzt. Der Versatz ist das, was ein Rautenfeld von einem Karogitter
% unterscheidet.
%
% Beschnitten wird auf den Textrahmen, nicht auf die Kartenkante. Ueber die
% ganze Karte gelegt deckte das Feld den Zierrand zu — und der Zierrand ist
% das, woran man die Karte erkennt. Innerhalb des Rahmens liegt es auf dem
% Pergament und laesst Schuppenband und Messingecken frei.
%
% Die Kachel ist 215 x 259 px; bei 14 mm Hoehe ist sie 11,62 mm breit.
% Sechs Spalten und elf Zeilen decken die 57 x 64,2 mm des Rahmens mit
% Ueberhang, den der Beschnitt wegnimmt. Elf Zeilen, weil der Zeilenschritt
% nur die halbe Kachelhoehe ist: die Reihen greifen ineinander, sonst
% klaffte zwischen zwei Rauten ein Rhombus aus blankem Pergament.
\newlength{\dsakartenrautenkachel} \setlength{\dsakartenrautenkachel}{14mm}
\newlength{\dsakartenrautenschritt} \setlength{\dsakartenrautenschritt}{11.62mm}
\newcommand{\dsaRueckenRautenfeld}{%
  \begin{scope}
    \clip (\dsakartenrahmenlinks,-\dsakartenrahmenoben)
      rectangle ($(\dsakartenrahmenlinks,-\dsakartenrahmenoben)
                  +(\dsakartenrahmenbreite,-\dsakartenrahmenhoehe)$);
    \foreach \dsa@rz in {0,...,10}{%
      \foreach \dsa@rs in {0,...,5}{%
        \node[anchor=center, inner sep=0, outer sep=0]
          at ({\dsakartenrahmenlinks
               + \dsa@rs*\dsakartenrautenschritt
               + mod(\dsa@rz,2)*0.5*\dsakartenrautenschritt},
              {-\dsakartenrahmenoben - \dsa@rz*0.5*\dsakartenrautenkachel})
          {\includegraphics[height=\dsakartenrautenkachel]%
                           {\dsagrafik{\dsa@rautenbild}}};}}
  \end{scope}}

% Was noch im Baukasten liegt und nicht taugt, damit es niemand ein zweites
% Mal probiert:
%
%   ornament-mittig   17,4 x 81,6 mm, fast Kartenhoehe, und als senkrechte
%                     Leiste in der Kartenmitte zunaechst verlockend. Es ist
%                     aber das MITTELSTUECK einer dreiteiligen Leiste und
%                     traegt rechts eine dunkle Anschlusskante, die ohne
%                     Zuschnitt als schwarzer Balken auf dem Pergament steht.
%   ornament-links    815 x 815 px, ein Eckbeschlag mit Messingring. Schoen,
%   ornament-rechts   aber auf 69 mm angelegt — auf einer 63 x 88 mm grossen
%                     Karte deckt ein Stueck davon die halbe Flaeche. Wer es
%                     will, schneidet den Ring mit werkzeuge/freistellen.py
%                     heraus und setzt ihn wie \dsaRueckenRaute.
\newcommand{\dsa@ruecken}{\dsaRueckenRaute}
\newcommand{\dsaKartenruecken}[1]{\renewcommand{\dsa@ruecken}{#1}}

% Die fertige Rueckseite. Keine Kartennummer: ein Ruecken traegt keine,
% sonst waere er nicht mehr generisch und verriete beim Mischen, welche
% Karte darunterliegt.
\newcommand{\dsa@rueckseite}{%
  \dsa@wenngesetzt{\dsa@rueckflaeche}%
    {\dsa@kartenblattauf{\dsa@rueckflaeche}{\dsa@ruecken}}%
  \dsa@wennleer{\dsa@rueckflaeche}%
    {\dsa@kartenblatt{\dsa@ruecken}}}

% Das Gegenstueck zu \dsa@wenngesetzt.
\newcommand{\dsa@wennleer}[2]{%
  \begingroup\edef\dsa@feld{#1}%
  \expandafter\endgroup\expandafter\ifstrempty\expandafter{\dsa@feld}{#2}{}}

% --- Verbrauchsgegenstand ----------------------------------------------
%
% Einseitig: Name, Untertitel, Abbildung, Wirkung. Mehr braucht ein
% Heiltrank nicht, und zehn davon im Gepaeck sollen sich nicht wie zehn
% Regelseiten anfuehlen. Die Rueckseite ist der generische Ruecken aus
% Abschnitt 18, damit ein Stapel gemischt werden kann.
%
% Der Aufbau unterscheidet sich von allen anderen Typen: der Text steht
% UNTEN und waechst nach oben, die Abbildung fuellt, was dazwischen bleibt.
% Deshalb wird der Text zuerst in eine Box gesetzt und ausgemessen.
\newsavebox{\dsa@wirkungbox}
\newlength{\dsa@wirkunghoehe}

\newcommand{\dsa@verbrauchseite}{%
  \global\dsa@ersterabsatztrue
  \sbox{\dsa@kopfbox}{%
    \vtop{\hsize=\dsakartensatzbreite
          \parindent=0pt \parskip=0pt
          \normalsize
          \dsaKartenkopf{\dsa@f@name}{\dsa@f@untertitel}}}%
  \global\dsa@ersterabsatztrue
  \sbox{\dsa@wirkungbox}{%
    \vbox{\hsize=\dsakartensatzbreite
          \parindent=0pt \parskip=0pt
          \dsa@engersatz
          \normalsize
          \color{dsakartenschrift}%
          \dsa@f@rueck}}%
  \setlength{\dsa@wirkunghoehe}{%
    \dimexpr\ht\dsa@wirkungbox+\dp\dsa@wirkungbox\relax}%
  \dsa@kartenblatt{%
    % Das Bildfeld: von der Unterkante des Kopfs bis eine Zeile ueber den
    % Text. Faellt es kleiner als 12 mm aus, steht zu viel Text auf der
    % Karte — dann ist es kein Verbrauchsgegenstand mehr, sondern ein
    % Gegenstand, und dafuer gibt es dsaKarteGegenstand.
    \dsa@kartenbildbis
      {\dsa@f@bild}
      {\dimexpr\dsakartenerstezeile+\dp\dsa@kopfbox\relax}
      {\dimexpr\dsakartenrahmenunten-\dsa@wirkunghoehe
       -\dsakartenzeilenschritt\relax}%
    \node[anchor=base west, inner sep=0, outer sep=0,
          text=dsakartenschrift]
      at (\dsakartensatzlinks,-\dsakartenerstezeile)
      {\usebox{\dsa@kopfbox}};
    \node[anchor=south west, inner sep=0, outer sep=0]
      at (\dsakartensatzlinks,-\dsakartenrahmenunten)
      {\usebox{\dsa@wirkungbox}};
    \dsa@kartennummer{\dsa@f@nummer}}}

\newenvironment{dsaKarteVerbrauch}{%
  \dsa@felderleeren
  \dsaKartenuntertitel{Verbrauchsgegenstand}\ignorespaces}{%
  \dsa@karteabliefern{\dsa@verbrauchseite}{\dsa@rueckseite}}

% --- Die neutrale Textkarte --------------------------------------------
%
% Kopf und Text, sonst nichts: kein Bild, keine Tabelle, kein Raster. Das
% ist die Bauform der Karten, die ein Set ueber sich selbst setzt — die
% Impressumskarte des Flusslande-Sets (H 001) und die Regelkarte des
% Meisterpersonen-Sets (AMP, Seite 3 und 4). Beide tragen auf Vorder- und
% Rueckseite dasselbe.
%
% Sie ist zugleich der Auffangtyp: was im Set eine Gattungszeile traegt,
% die keiner der anderen Umgebungen entspricht, laesst sich damit setzen.
\newenvironment{dsaKarteText}{%
  \dsa@felderleeren\ignorespaces}{%
  \dsa@textkartesetzen}

% Die Impressumskarte. Nichts weiter als eine Textkarte, deren Kopf schon
% steht; gesetzt wird sie mit \dsaKartenzeile.
\newenvironment{dsaKarteImpressum}{%
  \dsa@felderleeren
  \dsaKartenname{Impressum}\ignorespaces}{%
  \dsa@textkartesetzen}

\endinput

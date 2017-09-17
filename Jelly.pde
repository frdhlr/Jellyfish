/**
* Une meduse, caracterisee par :
* - un type, qui influe sur la représentation des tentacules
* - une taille
* - une couleur (en mode RVB)
* - des données de pulsation (pulsation courante et frequence)
* - des tentacules
* - une strate d'affichage
* - une position
*
* @see Tentacle
*/
class Jelly {
    /**
    * Type des tentacules :
    *    1 : tentacules "droits"
    *   -1 : tentacules "entortilles"
    *
    * @see Tentacle
    */
    private int type;

    /**
    * Taille de la meduse
    * Cette taille est reduite en fonction de la strate a laquelle appartient la meduse
    *
    * @see depth
    */
    private float size;

    /**
    * Composante rouge de la couleur du tentacule
    */
    private float colorRed;

    /**
    * Composante verte de la couleur du tentacule
    */
    private float colorGreen;

    /**
    * Composante bleue de la couleur du tentacule
    */
    private float colorBlue;

    /**
    * Pulsation courante (representee par un angle)
    */
    private float pulsation;

    /**
    * Frequence de battement de la meduse
    */
    private float frequency;

    /**
    * Tentacules de la meduse
    */
    private Tentacle[] tentacles;

    /**
    * Strate d'affichage de la meduse
    * En fonction de la profondeur de la strate, un coefficient réducteur est applique à la taille de la meduse pour simuler l'eloignement
    */
    private int depth;

    /**
    * Position de la meduse
    * Evolue au fil du temps et des courants marins
    */
    private PVector position;


    /**
    * Constructeur de meduse
    *
    * @param _size         Taille de la meduse
    * @param _red          Composante rouge de la couleur de la meduse
    * @param _green        Composante verte de la couleur de la meduse
    * @param _blue         Composante bleue de la couleur de la meduse
    * @param _nbTentacles  Nombre de tentacules de la meduse
    * @param _depth        Strate d'affichage de la meduse
    * @param _pos          Position initiale de la meduse
    */
    Jelly(float _size, float _colorRed, float _colorGreen, float _colorBlue, int _nbTentacles, int _depth, PVector _position) {
        //***************************************************************************************************
        // Variables locales
        //***************************************************************************************************
        PVector tentaclePos;    // Position relative de chaque tentacule
        float tentacleOffset;   // Decalage des tentacules par rapport aux bords de la meduse
        float tentacleStep;     // Ecart entre chaque tentacule

        //***************************************************************************************************
        // Calculs pour les position des tentacules
        //***************************************************************************************************
        tentaclePos    = new PVector(0, 10);                                 // Tous les tentacules sont décalés de 10 px vers le bas par rapport au centre de la meduse
        tentacleOffset = 10.0;                                               // On laisse 10 px de chaque cote de la meduse
        tentacleStep   = (_size - 2 * tentacleOffset) / (_nbTentacles - 1);  // Espace entre chaque tentacule

        //***************************************************************************************************
        // Détermination aleatoire du type des tentacules
        //***************************************************************************************************
        type = floor(random(2));
        if(type == 0) type = -1;

        //***************************************************************************************************
        // Affectation des caractéristiques de la meduse
        //***************************************************************************************************
        size       = _size;
        colorRed   = _colorRed;
        colorGreen = _colorGreen;
        colorBlue  = _colorBlue;

        //***************************************************************************************************
        // Détermination aleatoire des caracteristique du battement de la meduse
        //***************************************************************************************************
        pulsation  = random(TWO_PI);
        frequency  = random(5.0, 6.0);

        //***************************************************************************************************
        // Affectation de la strate et de la position initiale de la meduse
        //***************************************************************************************************
        depth      = _depth;
        position   = _position;

        //***************************************************************************************************
        // Creation des tentacules
        //***************************************************************************************************
        tentacles = new Tentacle[_nbTentacles];

        for(int i = 0; i < _nbTentacles; i++) {
            tentaclePos.x = i * tentacleStep - size / 2 + tentacleOffset;  // Affectation de la position horizontale du tentacule, en valeur relative par rapport au centre de la meduse
            tentacles[i] = new Tentacle(_colorRed, _colorGreen, _colorBlue, tentaclePos);
        }
    }


    /**
    * Deplace cette meduse et ses tentacules
    *
    * La nouvelle position de la meduse est calculee a partir du courant marin de la case sur laquelle se trouve la meduse
    */
    void move() {
        //***************************************************************************************************
        // Variables locales
        //***************************************************************************************************
        int posX, posY;
        float sinPulsation;  // Le sinus de la pulsation courante

        //***************************************************************************************************
        // Calcul de l'angle courant, en fonction de l'offset, de la frequence et du nombre courant de frames
        //***************************************************************************************************
        //pulsation = offSet + radians(frameCount) * frequency;
        pulsation += radians(1.0) * frequency;

        //***************************************************************************************************
        // On ralentit artificiellement la meduse pour plus de realisme
        //***************************************************************************************************
        if(frameCount % PI < 1) {
            //*************************************************************************************************
            // Calcul de la case de l'ocean sur laquelle se trouve la meduse
            //*************************************************************************************************
            posX = int(position.x / OCEAN_SCALE);
            posY = int(position.y / OCEAN_SCALE);

            //*************************************************************************************************
            // Calcul de la nouvelle position
            //*************************************************************************************************
            position.add(ocean[depth][posX][posY]);

            sinPulsation = sin(pulsation);

            if(sinPulsation > 0) {
                position.add(new PVector(0.0, -2.5 * sinPulsation));
            }

            //*************************************************************************************************
            // Gestion de la sortie d'ecran
            // Les courants étant forcement ascendant, pas la peine de tester si pos.y >= height
            //*************************************************************************************************
            if(position.x <= 0) position.x = width - 1;
            if(position.y <= 0) position.y = height - 1;

            if(position.x >= width) position.x = 1;

            //*************************************************************************************************
            // Deplacement des tentacules
            //*************************************************************************************************
            for (int i = 0; i < tentacles.length; i++) {
                tentacles[i].move(type, ocean[depth][posX][posY]);
            }
        }
    }


    /**
    * Affiche cette meduse et ses tentacules
    */
    void display() {
        blendMode(ADD);

        //***************************************************************************************************
        // Affichage de la meduse et de ses tentacules
        // On repositionne l'origine des coordonnées au centre de la meduse, et tout est affiche par rapport a ce centre
        //***************************************************************************************************
        pushMatrix();
        translate(position.x, position.y);
        scale(0.5f + 0.2f * depth);  // Plus la strate est profonde, plus la meduse est ses tentacules sont petits (effet d'eloignement)

        //***************************************************************************************************
        // Affichage des tentacules
        //***************************************************************************************************
        for (int i = 0; i < tentacles.length; i++) {
            tentacles[i].display(depth);
        }

        //***************************************************************************************************
        // Affichage du chapeau
        //***************************************************************************************************
        displayHead();

        popMatrix();

        blendMode(BLEND);
    }


    /**
    * Affiche le chapeau de cette meduse, en utilisant l'angle courant pour gerer la pulsation
    */
    private void displayHead() {
        //***************************************************************************************************
        // Variables locales
        //***************************************************************************************************
        float cosPulsation;  // Le cosinus de la pulsation courante
        float cosPulsationTimes2, cosPulsationTimes5, cosPulsationTimes10, cosPulsationTimes15;  // Le cosinus de la pulsation courante * 2, 5, 10 ou 15

        noStroke();

        cosPulsation        = cos(pulsation);
        cosPulsationTimes2  = cosPulsation * 2.0;
        cosPulsationTimes5  = cosPulsation * 5.0;
        cosPulsationTimes10 = cosPulsation * 10.0;
        cosPulsationTimes15 = cosPulsation * 15.0;

        //***************************************************************************************************
        // Affichage du chapeau de la meduse
        // Ce chapeau est constitue de 4 ellipses semi-transparentes, qui se dilatent et se contractent grace a l'angle
        //***************************************************************************************************
        fill(color(colorRed, colorGreen, colorBlue, 15));
        ellipse(0, 0, 100, 50 - cosPulsationTimes2);

        //fill(color(colorRed, colorGreen, colorBlue, 15));
        ellipse(0, 0 + 10 - cosPulsationTimes5, 120 + cosPulsationTimes10, 40 - cosPulsationTimes10);

        fill(color(colorRed, colorGreen, colorBlue, 10));
        ellipse(0, 0 + 20 - cosPulsationTimes10, 140 + cosPulsationTimes15, 50 - cosPulsationTimes10);

        fill(color(161, 244, 224, 15));
        ellipse(0, 0, 90, 40 - cosPulsationTimes2);

        //***************************************************************************************************
        // Et on ajoute un reflet pour faire joli
        //***************************************************************************************************
        fill(color(255, 255, 255, 50));
        ellipse(20, -10, 20, 10);
    }
}

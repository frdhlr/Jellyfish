/**
* Un tentacule, caracterise par :
* - un nombre de segments (plus il y de segments, plus le tentacule est long)
* - une couleur (en mode RVB)
* - une position relative par rapport au centre du chapeau de la meduse à laquelle le tentacule appartient
* - un ensemble d'origine pour le bruit de Perlin qui va permettre de faire evoluer la longueur de chaque segment
* - un ensemble d'origine pour le bruit de Perlin qui va permettre de faire evoluer l'orientation chaque segment
* - la longueur de chaque segment, sous la forme d'un vecteur
* - l'orientation de chaque segment, sous la forme d'un vecteur
*
* Un tentacule est constitue de n segment, chaque segment etant represente par une courbe de Bezier
* Chaque segment possède :
* - 1 longueur, exprimee sous forme d'un vecteur, et qui varie en fonction d'un bruit de Perlin
* - 2 points de controle, exprimes sous forme de vecteurs
*
* Pour le 1er segment :
* - le 1er point d'ancrage est la position du tentacule
* - le 2eme point d'ancrage est obtenu en ajoutant la longueur au 1er point d'ancrage
* - le 1er point de controle est obtenu en ajoutant le 1er vecteur de controle au 1ere point d'ancrage, ce vecteur est etire sur l'axe des y, pour le verticaliser
* - le 2eme point de controle est obtenu en ajoutant le 2eme vecteur de controle au 2eme point d'ancrage
*
* Ensuite, pour chaque segment s :
* - le 1er point d'ancrage est le 2eme point d'ancrage du segment precedent
* - le 2eme point d'ancrage est obtenu en ajoutant la longueur au 1er point d'ancrage
* - le 1er point de controle est obtenu en ajoutant l'inverse du vecteur de controle s au 1ere point d'ancrage
* - le 2eme point de controle est obtenu en ajoutant le vecteur de controle s+1 au 2eme point d'ancrage
*
* Pour un tentacule a n segment, on a ainsi :
* - n vecteurs de longueur
* - n+1 vecteurs d'orientation
*/
class Tentacle {
    /**
    * Nombre de segments du tentacule
    */
    private int nbSegments;

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
    * Position du tentacule
    */
    private PVector position;

    /**
    * Origines pour les bruits de Perlin servant a faire evoluer les longueurs
    */
    private PVector[] segmentLengthSeed;

    /**
    * Origines pour les bruits de Perlin servant a faire evoluer les orientations
    */
    private PVector[] segmentOrientationSeed;

    /**
    * Longueur pour chaque segment, qui evoluent au cours du temps
    */
    private PVector[] segmentLength;

    /**
    * Longueur pour chaque orientation, qui evoluent au cours du temps
    */
    private PVector[] segmentOrientation;

    /**
    * Constructeur de tentacule
    *
    * @param _colorRed          Composante rouge de la couleur du tentacule
    * @param _colorGreen        Composante verte de la couleur du tentacule
    * @param _colorBlue         Composante bleue de la couleur du tentacule
    * @param _position          Position initiale de la meduse
    */
    Tentacle(float _colorRed, float _colorGreen, float _colorBlue, PVector _position) {
        //***************************************************************************************************
        // Initialisation du nombre de segments
        //***************************************************************************************************
        nbSegments = 3;

        //***************************************************************************************************
        // Affectation de la couleur et de laposition initiale
        //***************************************************************************************************
        colorRed   = _colorRed;
        colorGreen = _colorGreen;
        colorBlue  = _colorBlue;

        position   = _position.copy();

        //***************************************************************************************************
        // Affectation des origines, des longueurs et des orientations
        // Les origines sont determinees aleatoirement
        // Les longueurs et les orientations sont generees a partir de bruits de Perlin, bases sur les origines
        //***************************************************************************************************
        segmentLengthSeed      = new PVector[nbSegments];
        segmentOrientationSeed = new PVector[nbSegments + 1];
        segmentLength          = new PVector[nbSegments];
        segmentOrientation     = new PVector[nbSegments + 1];

        for(int i = 0; i < nbSegments; i++) {
            segmentLengthSeed[i] = new PVector(random(10000), random(10000));
            segmentLength[i]     = new PVector(noise(segmentLengthSeed[i].x) * 100, noise(segmentLengthSeed[i].y) * 100);
        }

        for(int i = 0; i <= nbSegments; i++) {
            segmentOrientationSeed[i] = new PVector(random(10000), random(10000));
            segmentOrientation[i]     = new PVector(noise(segmentOrientationSeed[i].x) * 50, noise(segmentOrientationSeed[i].y) * 50);
        }
    }

    /**
    * Fait varier la longueur et les orientations de chaque segment du tentacule
    * La position du tentacule n'a pas besoin d'etre recalculee, car elle est exprimee de maniere relative par rapport a la position de la meduse
    *
    * @param _type          Type du tentacule (-1, 1) : influe sur l'orientation des segments
    * @param _currentSpeed  Vitesse de la meduse : influe sur l'orientation globale du tentacule (si la meduse va vers la droite, le tentacule est oriente vers la gauche)
    */
    void move(int _type, PVector _currentSpeed) {
        //***************************************************************************************************
        // Variables locales
        //***************************************************************************************************
        float tentacleDirection;  // Direction du tentacule

        //***************************************************************************************************
        // Calcul de la direction du tentacule
        // Le but est que le tentacule s'oriente dans le sens inverse de la vitesse de la meduse
        // Cette variable sert a adapter la position horizontale de chaque fin de segment
        //***************************************************************************************************
        tentacleDirection = _currentSpeed.x / abs(_currentSpeed.x) * -1.0f;

        //***************************************************************************************************
        // Evolution de la longueur de chaque segment, selon un bruit de Perlin
        //***************************************************************************************************
        for(int i = 0; i < nbSegments; i++) {
            segmentLengthSeed[i].x += 0.0080f;
            segmentLengthSeed[i].y += 0.0080f;
            segmentLength[i].x = noise(segmentLengthSeed[i].x) * 100.0f * tentacleDirection;
            segmentLength[i].y = noise(segmentLengthSeed[i].y) * 150.0f;
        }

        //***************************************************************************************************
        // Evolution de l'orientation de chaque segment, selon un bruit de Perlin
        // Le type du tentacule sert a adapter l'orientation horizontale de chaque segment
        //***************************************************************************************************
        for(int i = 0; i <= nbSegments; i++) {
            segmentOrientationSeed[i].x += 0.0080f;
            segmentOrientationSeed[i].y += 0.0080f;
            segmentOrientation[i].x = noise(segmentOrientationSeed[i].x) * 50.0f * tentacleDirection * _type;
            segmentOrientation[i].y = noise(segmentOrientationSeed[i].y) * 50.0f;

            if(i == 0) segmentOrientation[i].y *= 2.5f;  // Le 1er point de controle du 1er segment est etire verticalement pour que le 1er segment soit plus vertical
        }
    }


    /**
    * Affiche ce tentacule
    *
    * @param _depth    Strate d'afichage : sert a moduler l'epaisseur du tentacule, pour creer un effet de profondeur
    */
    void display(int _depth) {
        //***************************************************************************************************
        // Variables locales
        //***************************************************************************************************
        PVector[] endPoints = new PVector[nbSegments];  // Point final de chaque segment
        int iNext, iNextNext;

        //***************************************************************************************************
        // Calcul du point final de chaque segment
        // Chaque point final est obtenu en ajoutant la longueur au poin de depart du segment
        //***************************************************************************************************
        endPoints[0] = PVector.add(position, segmentLength[0]);

        for(int i = 1; i < nbSegments; i++) {
            endPoints[i] = PVector.add(endPoints[i - 1], segmentLength[i]);
        }

        //***************************************************************************************************
        // On dessine une ellipse sur chaque point final, pour faire joli
        //***************************************************************************************************
        noStroke();
        fill(color(colorRed, colorGreen, colorBlue, 60));

        for(int i =0; i < nbSegments; i++) {
            ellipse(endPoints[i].x, endPoints[i].y, 3, 3);
        }

        stroke(color(colorRed, colorGreen, colorBlue, 50));
        strokeWeight(0.5 + _depth / 2.0f);
        noFill();

        //***************************************************************************************************
        // Chaque segment est represente par une courbe de Bezier
        //***************************************************************************************************
        bezier(position.x,                               position.y,
        position.x     + segmentOrientation[0].x, position.y     + segmentOrientation[0].y,
        endPoints[0].x - segmentOrientation[1].x, endPoints[0].y - segmentOrientation[1].y,
        endPoints[0].x,                           endPoints[0].y);

        for(int i = 0; i < nbSegments - 1; i++) {
            iNext = i + 1;
            iNextNext = iNext + 1;

            bezier(endPoints[i].x,                                       endPoints[i].y,
            endPoints[i].x     + segmentOrientation[iNext].x,     endPoints[i].y     + segmentOrientation[iNext].y,
            endPoints[iNext].x - segmentOrientation[iNextNext].x, endPoints[iNext].y - segmentOrientation[iNextNext].y,
            endPoints[iNext].x,                                   endPoints[iNext].y);
        }
    }
}

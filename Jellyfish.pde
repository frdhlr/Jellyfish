//***************************************************************************************************************
// Jellyfish - Deep from the ocean
//
// Pulsating jellyfish with Bezier's tentacles, in a Perlin's ocean
//
// Keywords : Bezier curves, Perlin noise
//***************************************************************************************************************

//***************************************************************************************************************
// Constantes pour définir l'environnement
//***************************************************************************************************************
final static int   OCEAN_SCALE = 10;    // Taille de chaque case composant l'ocean
final static int   OCEAN_DEPTH = 4;     // Profondeur de l'ocean : nombre de strates d'affichage
final static float OCEAN_STEP  = 0.9f;  // Variation pour le bruit de Perlin simulant les courants marins
final static int   NB_JELLYS   = 8;     // Nombre de méduses par strate //12

//***************************************************************************************************************
// Variables globales décrivant l'ocean
//***************************************************************************************************************
int oceanWidth;                           // Largeur de l'ocean : nombre horizontal de cases
int oceanHeight;                          // Hauteur de l'ocean : nombre vertical de cases
PVector[][][] ocean;                      // Tableau de vecteurs décrivant les courants marins de l'ocean

//***************************************************************************************************************
// Variable globale contenant les meduses
//***************************************************************************************************************
Jelly[][] jelly = new Jelly[OCEAN_DEPTH][NB_JELLYS];


//***************************************************************************************************************
// Fonction implementant les parametres d'affichage
//***************************************************************************************************************
void settings() {
    fullScreen();
    smooth();
}

//***************************************************************************************************************
// Fonction d'initialisation
//***************************************************************************************************************
void setup() {
    //*************************************************************************************************************
    // Variables locales
    //*************************************************************************************************************
    float xScaleDirection;  // Coefficient multiplicateur et direction du courant marin (>0 : vers la droite, <0 : vers la gauche)

    noCursor();

    //*************************************************************************************************************
    // Creation de l'ocean
    // L'ocean est un semble de cases, chacune contenant un courant marin
    // Les courants marins sont modelises par des bruits de Perlin de dimension 2
    // Les courants vont forcement vers le haut et leur direction horizontale dépend de la strate
    //*************************************************************************************************************
    oceanWidth  = width / OCEAN_SCALE;
    oceanHeight = height / OCEAN_SCALE;

    ocean = new PVector[OCEAN_DEPTH][oceanWidth][oceanHeight];

    for(int x = 0; x < OCEAN_DEPTH; x++) {
        // La direction des courants alternent entre chaque strate
        if(x % 2 == 0) xScaleDirection = 2.5f;
        else           xScaleDirection = -2.5f;

        for(int y = 0; y < oceanWidth; y++) {
            for(int z = 0; z < oceanHeight; z++) {
                ocean[x][y][z] = new PVector(noise(y * OCEAN_STEP, z * OCEAN_STEP) * xScaleDirection, noise(1000 + y * OCEAN_STEP, 1000 + z * OCEAN_STEP) * -1.5f);
            }
        }
    }

    //***************************************************************************************************************
    // Peuplement de l'ocean avec les meduses
    //***************************************************************************************************************
    for(int i = 0; i < OCEAN_DEPTH; i++) {
        for(int j = 0; j < NB_JELLYS; j++) {
            // Parametres pour creer une meduse : taille, composantes de la couleur (rouge, vert, bleu), nombre de tentacules, strate, position
            jelly[i][j] = new Jelly(100, random(100, 255), random(100, 255), random(100, 255), int(random(5, 12)), i, new PVector(random(width), random(height)));
        }
    }
}

//***************************************************************************************************************
// Fonction repetitive
//***************************************************************************************************************
void draw() {
    println(frameRate);

    for(int i = 0; i < OCEAN_DEPTH; i++) {

        //***********************************************************************************************************
        // Pour chaque strate, on fait vivre les meduses : deplacement et afichage
        // La strate 0 est la plus profonde, la strate OCEAN_DEPTH - 1 la plus proche
        //***********************************************************************************************************
        for(int j = 0; j < NB_JELLYS; j++) {
            jelly[i][j].move();
            jelly[i][j].display();
        }

        //***********************************************************************************************************
        // Et on affiche un fond semi-transparent pour creer un effet de profondeur
        // Plus la strate est profonde, moins le fond est transparent
        //***********************************************************************************************************
        fill(color(7, 59, 150, 25 - i * 10));
        rect(0, 0, width, height);
    }
}

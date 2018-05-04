//PLANO
//reconhecer uma mesma face durante 5 segundos, dentro de um plano central de enquadramento
//enquadrar esta face e registrar a foto, salvando em arquivo
//enquanto isso, criar uma máscara preta com furo transparente no formato de cabeça
//criar uma apresentação que a cada 10 segundos lê uma nova foto e exibe para projeção
//
//requisitos:
//ter uma fila de exibição, e toda vez que cria uma foto nova, joga ela na frente
//permitir calibração de tamanho de cabeça e recorte

//CONFIGS
float headSize = 1.0;//proporção de tamanho
int posX = width/2;//posição da cabeça
int posY = height/2;
int exhibitInterval = 10;//em segundos
int shotInterval = 3;//em segundos
int detectInterval = 1;//em segundos
int brightness = 20;
float contrast = 3;

//BEGIN CODE
import processing.video.*;

//VARS
Capture cam;
FaceDetection fd;
BrightnessContrastController bc;
PImage img, mask;
int freshFaceCount = 1;
float tx,ty,sc,rz,ptx,pty,prz;
int mode = 0;
PVector origP;
String[] filenames;



void setup() {
  size(1920,1080);//fullScreen();
  frameRate(30);
  background(0);
  
  tx = 0;
  ty = 0;
  sc = 1;
  mask = loadImage("facemask.png");
  
  String[] cameras = Capture.list();
  for (int i = 0; i < cameras.length; i++) {
    println(i + " " + cameras[i]);
  }
  cam = new Capture(this, 1920, 1080, cameras[107], 30);
  cam.start();
  
  fd = new FaceDetection(this, cam);
  
  bc = new BrightnessContrastController();
}

//atualiza a fonte da câmera
void captureEvent(Capture cam) {
  cam.read();
}

void draw() {
  //exibição de arquivos salvos
  if(frameCount % exhibitInterval*frameRate == 0) {
    //troca de cabeça
    
    //TODO transformar isso aqui numa fila
    filenames = listFileNames(sketchPath()+"/faces");
    if(filenames != null) {
      img = loadImage("faces/"+filenames[(int)random(filenames.length)]);
      pushMatrix();
      translate(tx,ty);
      scale(sc);
      //rotateZ(rz);
      image(img,(width-img.width)/2,0);
      popMatrix();
    }
  }
  
  //if(frameCount % detectInterval*frameRate == 0 && freshFaceCount <= 0) {
    //if (cam.available() == true) {
    //  fd.detect(cam);//detecta a imagem de foco
    //}
    
    //if(fd.focusImg != null) {
    //  background(0);
    //  //TODO detectar durante um tempo antes de salvar
    //  img = fd.focusImg.get();
        
    //  //análise da imagem para contraste e brilho
    //  //img = bc.nondestructiveShift(img, brightness, contrast);
    //  pushMatrix();
    //  translate(tx,ty);
    //  scale(sc);
    //  mask.resize(img.width,img.height);
    //  img.mask(mask);
    //  image(img,(width-img.width)/2,0);
    //  popMatrix();
      
    //  //TODO salvar imagem e jogar pra fila de projeção
    //  saveFrame("faces/face####.png");
      
    //  //quando detecta uma
    //  freshFaceCount = (int)(exhibitInterval*frameRate);
    //}
  //}
  
  freshFaceCount--;
}

String[] listFileNames(String dir) {
  File file = new File(dir);
  if (file.isDirectory()) {
    String names[] = file.list();
    return names;
  } else {
    // If it's not a directory
    return null;
  }
}

void mousePressed() {
  origP = new PVector(mouseX,mouseY);
  ptx = tx;
  pty = ty;
}

void mouseDragged() {
  if(mode == 0) {
    tx = ptx - (origP.x - mouseX);
    ty = pty - (origP.y - mouseY);
  } else if(mode == 1) {
    if(mouseX > origP.x) sc += 0.01;
    if(mouseX < origP.x) sc -= 0.01;
  } 
}

void keyPressed() {
  switch(key) {
    case 't':
    mode = 0;
    break;
    case 's':
    mode = 1;
    break;
    case 'r':
    mode = 2;
    break;
  }
}
//END CODE
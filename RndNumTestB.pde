import java.util.Random;

PFont font;
Exception exception;

int lastWidth = 0;
int lastHeight = 0;

void setup() {
    //fullScreen();
    size(640, 480);
    surface.setResizable(true);
    
    Layout.applet = this;
    Global.applet = this;
    
    Application.init(this);
    
    Global.init();
    
    Layout.generateLayout(width, height);
}

void draw() {
    background(23);
    
    if (lastWidth != width || lastHeight != height) {
        lastWidth = width;
        lastHeight = height;
        Layout.generateLayout();
    }
    
    if (exception != null) {
        textSize(40);
        textAlign(LEFT, TOP);
        fill(255);
        text(exception.toString(), 0, 0, width, height);
        return;
    }
    
    textSize(15);
    textAlign(LEFT, TOP);
    fill(255);
    text(Application.getUpdateMessageCode(), 0, 0);
    
    //PGraphics pg = Global.generator.getGraphics((int)Global.generator.getAppropriateScale(width, height * (1 - Layout.buttonLayerHeight)) + 1);
    PGraphics pg = Global.generator.getGraphics(100);
    if (pg != null) {
        imageMode(CENTER);
        float scale = (float)Math.min((float)width / pg.width, height * (1 - Layout.buttonLayerHeight) / pg.height);
        image(pg, width / 2, height * (1 - Layout.buttonLayerHeight) / 2, pg.width * scale, pg.height * scale);
    }
        
    PGraphics interactableGraphics = createGraphics(width, height);
    interactableGraphics.beginDraw();
    Interactable.draw(interactableGraphics);
    interactableGraphics.endDraw();
    imageMode(CORNERS);
    image(interactableGraphics, 0, 0, width, height);
}

void stop(){
    Application.saveSettings();
}

void mousePressed() {
    Interactable.mousePressed(mouseX, mouseY);
}
void mouseDragged() {
    Interactable.mouseDragged(mouseX, mouseY);
}
void mouseReleased(){
    Interactable.mouseReleased();
}
void keyPressed() {
        println(key, keyCode);
    Interactable.keyPressed(key,keyCode);
}
void keyReleased() {
    Interactable.keyReleased(key, keyCode);
}
                            
void onSaveConfirmed(File file) {
    if (file == null) {
        Global.lastSaved = System.currentTimeMillis();
        Global.lastSaveFile = null;
        Global.saveState = 2;
        return;
    }
    PImage image = Global.generateSaveGraphics();
    try{
        image.save(file.getAbsolutePath());
        Global.lastSaveFile = file.getAbsolutePath().substring(file.getAbsolutePath().lastIndexOf(File.separator) + 1);
        Global.saveState = 0;
    }
    catch(Exception e) {
        Global.lastSaveFile = null;
        Global.saveState = 1;
    }
    Global.lastSaved = System.currentTimeMillis();
}
void onFontFileSelected(File file) {
    if (file == null) return;
    Global.setFont(file.getAbsolutePath());
}
static class Global{
    public static PApplet applet;
    public static PFont font;
    public static String fontPath;
    public static Generator generator;
    public static int selectedRow, selectedColumn;
    public static int outputScale = 10;
    
    public static long lastSaved = -5000;
    public static String lastSaveFile = "";
    public static int saveState = -1;
    
    public static void init(){
        Global.generateRandomGenerator();
    }

    public static void setOutputScale(int scale){
        Global.outputScale = scale;
        Application.saveSettings();
    }
    public static void setFont(String path) {
        try{
            Global.font = Global.applet.createFont(path, 60);
            Global.generator.setFont(Global.font);
            Global.fontPath = path;
            Application.saveSettings();
        }
        catch(Exception e) {
            println("Exception in font loading:");
        }
    }
    public static void generateRandomGenerator() {
        Global.generator = Generator.createRandomGenerator(Global.applet, Global.font, System.currentTimeMillis(), 20, 50);
        Global.selectedRow = -1;
        Global.selectedColumn = -1;
    }
    public static void recreateGenerator() {
        Global.generator = Generator.createRandomGenerator(Global.applet, Global.font, System.currentTimeMillis(), Global.generator.getRowCount(), Global.generator.getRowCharacterCount());
        Global.selectedRow = -1;
        Global.selectedColumn = -1;
    }
    public static void save() {
        Global.applet.selectOutput("Uložit jako...", "onSaveConfirmed");
    }
    public static void loadFont() {
        Global.applet.selectInput("Zvolit font...", "onFontFileSelected");
    }
    public static PGraphics generateSaveGraphics() {
        return Global.generator.getGraphics(Global.outputScale);
    }
}
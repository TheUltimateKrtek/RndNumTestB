import processing.core.*; 
import processing.data.*; 
import processing.event.*; 
import processing.opengl.*; 

import java.util.Random; 

import java.util.HashMap; 
import java.util.ArrayList; 
import java.io.File; 
import java.io.BufferedReader; 
import java.io.PrintWriter; 
import java.io.InputStream; 
import java.io.OutputStream; 
import java.io.IOException; 

public class RndNumTestB extends PApplet {



PFont font;
Exception exception;

int lastWidth = 0;
int lastHeight = 0;

public void setup(){
  //fullScreen();
  
  surface.setResizable(true);
  
  Layout.applet = this;
  Global.applet = this;
  
  Global.init();
  
  Layout.generateLayout(width, height);
  
  /*String projectFolder = "/sdcard/Sketchbook/RndNumTestB/";
  int total = 0;
  for(String file:new File(projectFolder).list()){
    if(!file.endsWith(".pde")) continue;
    int lines = loadStrings(projectFolder + file).length;
    println("The file \"" + file + "\" has " + lines + " lines.");
    total += lines;
  }
  println("In total, the project has " + total + " lines.");*/
}

public void draw(){
  background(23);

  if(lastWidth != width || lastHeight != height){
    lastWidth = width;
    lastHeight = height;
    Layout.generateLayout();
  }
  
  if(exception != null){
    textSize(40);
    textAlign(LEFT, TOP);
    fill(255);
    text(exception.toString(), 0, 0, width, height);
    return;
  }
  
  textSize(30);
  textAlign(LEFT, TOP);
  fill(255);
  Interactable interactingWithKeyboard = Interactable.getInteractingWithKeyboard();
  if(interactingWithKeyboard != null) text(interactingWithKeyboard.getName(), 0, 0);
  
  //PGraphics pg = Global.generator.getGraphics((int)Global.generator.getAppropriateScale(width, height * (1 - Layout.buttonLayerHeight)) + 1);
  PGraphics pg = Global.generator.getGraphics(100);
  if(pg != null){
    imageMode(CENTER);
    float scale = (float)Math.min((float)width / pg.width, height * (1 - Layout.buttonLayerHeight) / pg.height);
    image(pg, width / 2, height * (1 - Layout.buttonLayerHeight) / 2, pg.width * scale, pg.height * scale);
    //noFill();
    //stroke(63, 127, 255);
    //strokeWeight(1);
    //rectMode(CENTER);
    //rect(width / 2, height * (1 - Layout.buttonLayerHeight) / 2, pg.width * scale, pg.height * scale);
  }
  
  PGraphics interactableGraphics = createGraphics(width, height);
  interactableGraphics.beginDraw();
  Interactable.draw(interactableGraphics);
  interactableGraphics.endDraw();
  imageMode(CORNERS);
  image(interactableGraphics, 0, 0, width, height);
}

public void mousePressed(){
  Interactable.mousePressed(mouseX, mouseY);
}
public void mouseDragged(){
  Interactable.mouseDragged(mouseX, mouseY);
}
public void mouseReleased(){
  Interactable.mouseReleased();
}
public void keyPressed(){
  println(key, keyCode);
  Interactable.keyPressed(key, keyCode);
}
public void keyReleased(){
  Interactable.keyReleased(key, keyCode);
}

public void onSaveConfirmed(File file){
  if(file == null){
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
  catch(Exception e){
    Global.lastSaveFile = null;
    Global.saveState = 1;
  }
  Global.lastSaved = System.currentTimeMillis();
}
public void onFontFileSelected(File file){
  if(file == null) return;
  Global.setFont(file.getAbsolutePath());
}
abstract static public class Button extends Interactable{
  private String text;
  private int col;
  private int align;
  
  public Button(float x1, float y1, float x2, float y2, String name, String text, int col, int align){
    super(x1, y1, x2, y2, name);
    this.text = text;
    this.col = col;
    this.align = align;
  }
  
  final public String getText(){
    return this.text;
  }
  final public Button setText(String text){
    this.text = text == null ? "" : text;
    return this;
  }
  
  final public int getColor(){
    return this.col;
  }
  final public Button setColor(int col){
    this.col = col;
    return this;
  }
  
  final public int getAlign(){
    return this.align;
  }
  final public Button setAlign(int align){
    this.align = align;
    return this;
  }
  
  final protected void onMousePressed(float x, float y){}
  final protected void onMouseDragged(float x, float y){}
  final protected void onMouseReleased(){this.action();}
  final protected void onMouseMoved(float x, float y){}
  final protected void onPressedInterupted(){}
  final protected void onKeyPressed(char key, int keyCode){}
  final protected void onKeyReleased(char key, int keyCode){}
  final protected void onInteractionWithKeyboardStarted(){}
  final protected void onInteractionWithKeyboardEnded(){}
  final protected void onInteractionWithKeyboardInterupted(){}
  final protected void onMousePressedOutsideWhileInteractingWithKeyboard(){}
  protected int getHoverCursorIcon(float x, float y){return Interactable.Cursor.ARROW;}
  protected void onUpdate(){}
  protected void onDraw(PGraphics pg){
    pg.textSize(10);
    float textWidth = pg.textWidth(this.text) * 0.1f;
    float textSize = (float)Math.min(this.getWidth() / textWidth, this.getHeight());
    pg.textSize(textSize);
    pg.textAlign(this.align, PConstants.CENTER);
    pg.fill(this.col, (this.col >> 24) & 0xFF);
    pg.rectMode(CORNERS);
    if(this.align == PConstants.LEFT){
      pg.text(this.text, this.getLeft(), this.getCenterY() - textSize * 0.05f);
    }
    else if(this.align == PConstants.RIGHT){
      pg.text(this.text, this.getRight(), this.getCenterY() - textSize * 0.05f);
    }
    else{
      pg.text(this.text, this.getCenterX(), this.getCenterY() - textSize * 0.05f);
    }
  }
  abstract protected void action();
}
static class Generator{
  private PApplet applet;
  private Random random;
  private PFont font;
  private float characterWidth;
  private long seed;
  
  private int[] sizes;
  private int[] cols;
  private boolean[] lefts;
  
  private String[][] strings;
  
  private static final int[] possibleColors = new int[]{
    0xff54f1ff,
    0xffC2C200,
    0xff00FF00,
    0xffFF00FF,
    0xffFFFFFF,
    0xffFF1F1F
  };
  private static final float borderHeight = 0.2f;
  private static final float borderWidth = 0.5f;
  
  public Generator(PApplet applet, PFont font, long seed, int[] cols, int[] sizes, boolean[] lefts){
    if(applet == null || sizes == null || cols == null || lefts == null) throw new NullPointerException("Something is null");
    if(sizes.length == 0) throw new IllegalArgumentException("The size array is zero values long.");
    for(int i = 0; i < sizes.length; i ++){
      if(sizes[i] < 1) throw new IllegalArgumentException("One of the sizes is out of range. Index: " + i + ", Value: " + cols[i]);
    }
    if(cols.length == 0) throw new IllegalArgumentException("The col array is zero values long.");
    for(int i = 0; i < cols.length; i ++){
      if(cols[i] < 0 || cols[i] > 6) throw new IllegalArgumentException("One of the sizes is out of range. Index: " + i + ", Value: " + cols[i]);
    }
    if(lefts.length != sizes.length) throw new IllegalArgumentException("The lefts array is not the same length as the size array.");
    
    this.applet = applet;
    this.font = font;
    this.characterWidth = this.getCharacterWidth();
    this.seed = seed;
    this.random = new Random(this.seed);
    
    this.sizes = sizes;
    this.cols = cols;
    this.lefts = lefts;
    
    this.strings = new String[this.cols.length][this.sizes.length];
    for(int row = 0; row < this.strings.length; row ++){
      for(int column = 0; column < this.strings[row].length; column ++){
        strings[row][column] = this.generateRandomString(this.sizes[column]);
      }
    }
  }

  public Generator setFont(PFont font){
    this.font = font;
    return this;
  }
  
  static public int[] getAllColors(){
    int[] rl = new int[Generator.possibleColors.length];
    for(int i = 0; i < rl.length; i ++) rl[i] = Generator.possibleColors[i];
    return rl;
  }
  
  static public Generator createRandomGenerator(PApplet applet, PFont font, long seed, int maxRowCount, int maxCharacterCount){
    if(applet == null) throw new NullPointerException("Applet is null.");
    if(maxRowCount < 1 || maxCharacterCount < 1) throw new IllegalArgumentException();
    
    Random random = new Random(seed);
    
    IntList columnSizes = new IntList();
    int totalSize = 0;
    while(totalSize < maxCharacterCount){
      int left = maxCharacterCount - totalSize;
      int[] rnds = new int[]{
        random.nextInt(Math.min(left, 32)),
        random.nextInt(Math.min(left, 32))
      };
      int rndSize = Math.min(rnds[0], rnds[1]) + 1;
      columnSizes.append(rndSize);
      totalSize += rndSize;
    }
    
    int[] sizes = columnSizes.array();
    
    int[] cols = new int[maxRowCount];
    for(int i = 0; i < cols.length; i ++) cols[i] = random.nextInt(Generator.possibleColors.length);
    for(int i = 0; i < cols.length - 1; i ++){
      for(int j = 0; j < cols.length - i - 1; j ++){
        if(cols[j] > cols[j + 1]){
          int temp = cols[j];
          cols[j] = cols[j + 1];
          cols[j + 1] = temp;
        }
      }
    }
    boolean[] lefts = new boolean[sizes.length];
    for(int i = 0; i < lefts.length; i ++) lefts[i] = random.nextBoolean();
    
    return new Generator(applet, font, random.nextLong(), cols, sizes, lefts);
  }
  
  public int getColumnCount(){
    return this.sizes.length;
  }
  public int getRowCount(){
    return this.cols.length;
  }
  public int getRowCharacterCount(){
    int sum = 0;
    for(int i = 0; i < this.sizes.length; i ++) sum += this.sizes[i];
    return sum;
  }
  
  public Generator addRandomRow(int index){
    return this.addRow(index, this.random.nextInt(Generator.possibleColors.length));
  }
  public Generator addRow(int col){
    return this.addRow(Integer.MAX_VALUE, col);
  }
  public Generator addRow(int index, int col){
    if(col < 0 || col >= Generator.possibleColors.length) return this;
    index = Math.min(this.getRowCount(), Math.max(0, index));
    
    int[] cols = new int[this.cols.length + 1];
    String[][] strings = new String[this.strings.length + 1][this.strings[0].length];
    
    for(int row = 0; row < index; row ++){
      cols[row] = this.cols[row];
      for(int column = 0; column < this.getColumnCount(); column ++){
        strings[row][column] = this.strings[row][column];
      }
    }
    
    cols[index] = col;
    for(int column = 0; column < this.getColumnCount(); column ++){
      strings[index][column] = this.generateRandomString(this.sizes[column]);
    }
    
    for(int row = index + 1; row < cols.length; row ++){
      cols[row] = this.cols[row - 1];
      for(int column = 0; column < this.getColumnCount(); column ++){
        strings[row][column] = this.strings[row - 1][column];
      }
    }
    
    this.cols = cols;
    this.strings = strings;
    
    return this;
  }
  public Generator removeRow(int index){
    if(this.getRowCount() <= 1 || index < 0 || index >= this.getRowCount()) return this;
    
    int[] cols = new int[this.cols.length - 1];
    String[][] strings = new String[this.strings.length - 1][this.strings[0].length];
    
    for(int row = 0; row < index; row ++){
      cols[row] = this.cols[row];
      for(int column = 0; column < this.getColumnCount(); column ++){
        strings[row][column] = this.strings[row][column];
      }
    }
    
    for(int row = index; row < cols.length; row ++){
      cols[row] = this.cols[row + 1];
      for(int column = 0; column < this.getColumnCount(); column ++){
        strings[row][column] = this.strings[row + 1][column];
      }
    }
    
    this.cols = cols;
    this.strings = strings;
    
    return this;
  }
  public int getRowColorIndex(int index){
    if(index < 0 || index >= this.getRowCount()) return -1;
    return this.cols[index];
  }
  public int getRowColor(int index){
    if(index < 0 || index >= this.getRowCount()) return -1;
    return Generator.possibleColors[this.cols[index]];
  }
  public Generator setRowColorIndex(int index, int col){
    if(index < 0 || index >= this.getRowCount()) return this;
    this.cols[index] = col;
    return this;
  }
  
  public Generator addRandomColumn(int index){
    return this.addColumn(index, this.random.nextInt(32) + 1, this.random.nextBoolean());
  }
  public Generator addColumn(int size, boolean isLeftAligned){
    return this.addColumn(Integer.MAX_VALUE, size, isLeftAligned);
  }
  public Generator addColumn(int index, int size, boolean isLeftAligned){
    index = Math.min(this.getColumnCount(), Math.max(0, index));
    
    int[] sizes = new int[this.sizes.length + 1];
    boolean[] lefts = new boolean[this.lefts.length + 1];
    String[][] strings = new String[this.strings.length][this.strings[0].length + 1];
    
    for(int column = 0; column < index; column ++){
      sizes[column] = this.sizes[column];
      lefts[column] = this.lefts[column];
      for(int row = 0; row < this.getRowCount(); row ++){
        strings[row][column] = this.strings[row][column];
      }
    }
    
    sizes[index] = size;
    lefts[index] = isLeftAligned;
    for(int row = 0; row < this.getRowCount(); row ++){
      strings[row][index] = this.generateRandomString(size);
    }
      
    for(int column = index + 1; column < sizes.length; column ++){
      sizes[column] = this.sizes[column - 1];
      lefts[column] = this.lefts[column - 1];
      for(int row = 0; row < this.getRowCount(); row ++){
        strings[row][column] = this.strings[row][column - 1];
      }
    }
    
    this.sizes = sizes;
    this.lefts = lefts;
    this.strings = strings;
    
    return this;
  }
  public Generator removeColumn(int index){
    if(index < 0 || index >= this.getColumnCount() || this.getColumnCount() == 1) return this;
    
    int[] sizes = new int[this.sizes.length - 1];
    boolean[] lefts = new boolean[this.lefts.length - 1];
    String[][] strings = new String[this.strings.length][this.strings[0].length - 1];
    
    for(int column = 0; column < index; column ++){
      sizes[column] = this.sizes[column];
      lefts[column] = this.lefts[column];
      for(int row = 0; row < this.getRowCount(); row ++){
        strings[row][column] = this.strings[row][column];
      }
    }
    
    for(int column = index; column < sizes.length; column ++){
      sizes[column] = this.sizes[column + 1];
      lefts[column] = this.lefts[column + 1];
      for(int row = 0; row < this.getRowCount(); row ++){
        strings[row][column] = this.strings[row][column + 1];
      }
    }
    
    this.sizes = sizes;
    this.lefts = lefts;
    this.strings = strings;
    
    return this;
  }
  public int getColumnSize(int index){
    if(index < 0 || index >= this.getColumnCount()) return -1;
    return this.sizes[index];
  }
  public Generator setColumnSize(int index, int size){
    if(index < 0 || index >= this.getColumnCount()) return this;
    this.sizes[index] = size;
    for(int row = 0; row < this.getRowCount(); row ++){
      strings[row][index] = this.adaptString(strings[row][index], size);
    }
    return this;
  }
  public Generator setColumnSize(int index, int size, boolean generateNew){
    if(index < 0 || index >= this.getColumnCount()) return this;
    this.sizes[index] = size;
    for(int row = 0; row < this.getRowCount(); row ++){
      strings[row][index] = this.adaptString(strings[row][index], size, generateNew);
    }
    return this;
  }
  public boolean isColumnAlignedLeft(int index){
    if(index < 0 || index >= this.getColumnCount()) return false;
    return this.lefts[index];
  }
  public boolean isColumnAlignedRight(int index){
    if(index < 0 || index >= this.getColumnCount()) return false;
    return !this.lefts[index];
  }
  public Generator setColumnAlign(int index, boolean left){
    if(index < 0 || index >= this.getColumnCount()) return this;
    this.lefts[index] = left;
    return this;
  }
  
  public String getString(int row, int column){
    if(row < 0 || row >= this.getRowCount() || column < 0 || column >= this.getColumnCount()) return null;
    return this.strings[row][column];
  }
  public Generator setString(int row, int column, String string){
    if(row < 0 || row >= this.getRowCount() || column < 0 || column >= this.getColumnCount()) return null;
    if(string == null) return this;
    if(string.length() == 0) return this;
    char[] chars = string.toCharArray();
    for(int i = 0; i < chars.length; i ++){
      if(!Character.isDigit(chars[i])) return this;
    }
    this.strings[row][column] = adaptString(string, this.sizes[column]);
    return this;
  }
  
  public float getRowTop(int row, float scale){
    if(row < 0 || row >= this.getRowCount() || scale <= 0) return Float.NaN;
    return (Generator.borderHeight * (row + 2) + row) * scale;
  }
  public float getRowBottom(int row, float scale){
    if(row < 0 || row >= this.getRowCount() || scale <= 0) return Float.NaN;
    return (Generator.borderHeight * (row + 2) + row + 1) * scale;
  }
  public float getColumnLeft(int column, float scale){
    if(column < 0 || column >= this.getColumnCount() || scale <= 0) return Float.NaN;
    float sum = Generator.borderWidth * 2;
    for(int i = 0; i < column; i ++) sum += this.sizes[i] * this.characterWidth + Generator.borderWidth;
    return sum * scale;
  }
  public float getColumnRight(int column, float scale){
    if(column < 0 || column >= this.getColumnCount() || scale <= 0) return Float.NaN;
    float sum = Generator.borderWidth * 2;
    for(int i = 0; i < column; i ++) sum += this.sizes[i] * this.characterWidth + Generator.borderWidth;
    sum += this.sizes[column] * this.characterWidth;
    return sum * scale;
  }
  public float[] getStringBorders(int row, int column, float scale){
    if(row < 0 || row >= this.getRowCount() || column < 0 || column >= this.getColumnCount() || scale <= 0) return new float[]{Float.NaN, Float.NaN, Float.NaN, Float.NaN};
    float top = Generator.borderHeight * (row + 2) + row;
    float bottom = top + 1;
    float left = Generator.borderWidth * 2;
    for(int i = 0; i < column; i ++) top += this.sizes[i] * this.characterWidth + Generator.borderWidth;
    float right = this.sizes[column] * this.characterWidth;
    return new float[]{left * scale, top * scale, right * scale, bottom * scale};
  }
  public float[][] getAllRowBorders(float scale){
    float[][] rl = new float[this.getRowCount()][2];
    for(int row = 0; row < rl.length; row ++){
      float top = Generator.borderHeight * (row + 2) + row;
      float bottom = top + 1;
      rl[row] = new float[]{top * scale, bottom * scale};
    }
    
    return rl;
  }
  public float[][] getAllColumnBorders(float scale){
    float[][] rl = new float[this.getColumnCount()][2];
    rl[0][0] = Generator.borderWidth * 2;
    rl[0][1] = rl[0][0] + this.sizes[0] * this.characterWidth;
    for(int column = 1; column < rl.length; column ++){
      rl[column][0] = rl[column - 1][1] + Generator.borderWidth;
      rl[column][1] = rl[column][0] + this.sizes[column] * this.characterWidth;
    }
    for(int i = 0; i < rl.length; i ++){
      rl[i][0] *= scale;
      rl[i][1] *= scale;
    }
    return rl;
  }
  
  public float getGraphicsWidth(float scale){
    float sum = 0;
    for(int column = 0; column < this.getColumnCount(); column ++){
      sum += this.sizes[column] * this.characterWidth;
    }
    //sum += this.getRowCharacterCount() * this.characterWidth;
    sum += Generator.borderWidth * (3 + this.getColumnCount());
    return sum * scale;
  }
  public float getGraphicsHeight(float scale){
    return (Generator.borderHeight * (3 + this.getRowCount()) + this.getRowCount()) * scale;
  }
  public float getAppropriateScale(float w, float h){
    if(w < 1 || h < 1) return Float.NaN;
    return (float)Math.min(w / this.getGraphicsWidth(1), h / this.getGraphicsHeight(1));
  }
  
  public PGraphics getGraphics(int scale){
    float[][] rowBorders = this.getAllRowBorders(scale);
    float[][] columnBorders = this.getAllColumnBorders(scale);
    
    float width = columnBorders[columnBorders.length - 1][1] + Generator.borderWidth * scale * 2;
    float height = (rowBorders[rowBorders.length - 1][1] + Generator.borderHeight * scale * 2);
    
    PGraphics pg = this.applet.createGraphics((int)width, (int)height);
    pg.beginDraw();
    pg.background(0);
    if(this.font != null) pg.textFont(this.font);
    pg.textSize(scale);
    for(int row = 0; row < rowBorders.length; row ++){
      for(int column = 0; column < columnBorders.length; column ++){
        pg.fill(Generator.possibleColors[this.cols[row]], 255);
        
        float left = columnBorders[column][0];
        float right = columnBorders[column][1];
        float top = rowBorders[row][0];
        float bottom = rowBorders[row][1];
        
        //TODO: Character by character drawing
        if(this.lefts[column]){
          pg.textAlign(LEFT, CENTER);
          pg.text(this.strings[row][column], left, (top + bottom) * 0.5f);
        }
        else{
          pg.textAlign(RIGHT, CENTER);
          pg.text(this.strings[row][column], right, (top + bottom) * 0.5f);
        }
        
        //pg.noFill();
        //pg.stroke(255);
        //pg.strokeWeight(scale / 10);
        //pg.rectMode(CORNERS);
        //pg.rect(left, top, right, bottom);
      }
    }
    pg.endDraw();
    return pg;
    //TODO
  }
  
  private float getCharacterWidth(){
    PGraphics pg = this.applet.createGraphics(1, 1);
    pg.beginDraw();
    if(this.font != null) pg.textFont(this.font);
    pg.textSize(100);
    float textWidth = pg.textWidth("0") / 100;
    pg.endDraw();
    return textWidth;
  }
  
  private String generateRandomString(int size){
    int digits = this.random.nextInt(size) + 1;
    if(size == 1) return this.random.nextInt(10) + "";
    String rs = "";
    rs += this.random.nextInt(9) + 1;
    for(int i = 1; i < digits; i ++) rs += this.random.nextInt(10);
    return rs;
  }
  private String adaptString(String s, int size){
    if(s == null) return (this.random.nextInt(9) + 1) + "";
    if(s.length() >= size) s = s.substring(s.length() - size, s.length());
    if(s.startsWith("0") && s.length() > 1){
      int rnd = this.random.nextInt(9) + 1;
      s = rnd + s.substring(1, s.length());
    }
    return s;
  }
  private String adaptString(String s, int size, boolean generateNew){
    if(s == null) return (this.random.nextInt(9) + 1) + "";
    if(s.length() >= size) s = s.substring(s.length() - size, s.length());
    else if(generateNew){
      int[] rnds = new int[4];
      for(int i = 0; i < rnds.length; i ++) rnds[i] = this.random.nextInt(size - s.length());
      int rnd = this.min(rnds) + s.length();
      String string = this.generateRandomString(rnd);
      if(string.length() > s.length()){
        s = string.substring(string.length() - s.length()) + s;
        if(s.length() > size) s = s.substring(0, size);
      }
    }
    if(s.startsWith("0") && s.length() > 1){
      int rnd = this.random.nextInt(9) + 1;
      s = rnd + s.substring(1, s.length());
    }
    return s;
  }
  private int min(int... nums){
    if(nums.length == 0) return Integer.MIN_VALUE;
    int min = nums[0];
    for(int i:nums) min = Math.min(min, i);
    return min;
  }
  
  public Generator sortByColor(){
    int[] indexes = new int[this.cols.length];
    for(int i = 0; i < indexes.length; i ++) indexes[i] = i;
    
    for(int i = 0; i < indexes.length - 1; i ++){
      for(int j = 0; j < indexes.length - i - 1; j ++){
        if(this.cols[indexes[j]] > this.cols[indexes[j + 1]]){
          int temp = indexes[j];
          indexes[j] = indexes[j + 1];
          indexes[j + 1] = temp;
        }
      }
    }
    
    String[][] strings = new String[this.strings.length][this.strings[0].length];
    int[] cols = new int[this.cols.length];
    for(int row = 0; row < indexes.length; row ++){
      for(int column = 0; column < strings[0].length; column ++){
        strings[row][column] = this.strings[indexes[row]][column];
      }
      cols[row] = this.cols[indexes[row]];
    }
    this.strings = strings;
    this.cols = cols;
    return this;
  }
}
static class Global{
  public static PApplet applet;
  public static PFont font;
  public static Generator generator;
  public static int selectedRow, selectedColumn;
  public static int outputScale = 10;

  public static long lastSaved = -5000;
  public static String lastSaveFile = "";
  public static int saveState = -1;
  
  public static void setFont(String path){
    try{
      Global.font = Global.applet.createFont(path, 60);
      Global.generator.setFont(Global.font);
    }
    catch(Exception e){
      println("Exception in font loading:");
    }
  }  
  public static void init(){
    Global.setFont("/sdcard/Sketchbook/RndNumTest/data/DoppioOne-Regular.ttf");
    Global.generateRandomGenerator();
  }
  public static void generateRandomGenerator(){
    Global.generator = Generator.createRandomGenerator(Global.applet, Global.font, System.currentTimeMillis(), 20, 50);
    Global.selectedRow = -1;
    Global.selectedColumn = -1;
  }
  public static void recreateGenerator(){
    Global.generator = Generator.createRandomGenerator(Global.applet, Global.font, System.currentTimeMillis(), Global.generator.getRowCount(), Global.generator.getRowCharacterCount());
    Global.selectedRow = -1;
    Global.selectedColumn = -1;
  }
  public static void save(){
    Global.applet.selectOutput("Uložit jako...", "onSaveConfirmed");
  }
  public static void loadFont(){
    Global.applet.selectInput("Zvolit font...", "onFontFileSelected");
  }
  public static PGraphics generateSaveGraphics(){
    return Global.generator.getGraphics(Global.outputScale);
  }
}
static abstract public class Interactable extends Rect{
  static final private ArrayList<Interactable> instances = new ArrayList<Interactable>();
  static private Interactable interactingWithKeyboard;
  static private Interactable pressed;
  
  private String name;
  private boolean isActive, isDestroyed;
  
  private boolean isPressed;
  
  public static final class Cursor{
    public static final int ARROW = 0;
    public static final int CROSS = 1;
    public static final int HAND = 12;
    public static final int MOVE = 13;
    public static final int TEXT = 2;
    public static final int WAIT = 3;
  }
  
  public Interactable(float x1, float y1, float x2, float y2, String name){
    super(x1, y1, x2, y2);
    this.setName(name);
    this.isActive = true;
    
    this.isDestroyed = false;
    Interactable.instances.add(this);
  }
  
  public Interactable destroy(){
    synchronized(Interactable.instances){
      if(this.isDestroyed) return this;
      Interactable.instances.remove(this);
      this.interuptPressed();
      this.interuptInteractingWithKeyboard();
      this.isActive = false;
      this.isDestroyed = true;
      return this;
    }
  }
  public final boolean isDestroyed(){
    return this.isDestroyed;
  }
  
  public final static Interactable[] get(){
    synchronized(Interactable.instances){
      Interactable[] rl = new Interactable[Interactable.instances.size()];
      for(int i = 0; i < rl.length; i ++) rl[i] = Interactable.instances.get(i);
      return rl;
    }
  }
  public final static Interactable get(String name){
    synchronized(Interactable.instances){
      for(Interactable i:Interactable.instances){
        if(i.name.equals(name)) return i;
      }
      return null;
    }
  }
  public final static Interactable get(int index){
    synchronized(Interactable.instances){
      if(index < 0 || index >= Interactable.instances.size()) return null;
      return Interactable.instances.get(index);
    }
  }
  public final static Interactable get(String name, int index){
    synchronized(Interactable.instances){
      for(Interactable i:Interactable.instances){
        if(i.name.equals(name)) index --;
        if(index == 0) return i;
      }
      return null;
    }
  }
  public final static int size(){
    return Interactable.instances.size();
  }
  final public static void clear(){
    synchronized(Interactable.instances){
      while(Interactable.instances.size() > 0){
        Interactable.instances.get(0).destroy();
      }
    }
  }
  
  final public static Interactable getPressed(){
    return Interactable.pressed;
  }
  final public static boolean mousePressed(float x, float y){
    synchronized(Interactable.instances){
      for(int i = Interactable.instances.size() - 1; i >= 0; i --){
        Interactable interactable = Interactable.instances.get(i);
        if(!interactable.isActive || !interactable.isPointInside(x, y)) continue;
        if(Interactable.interactingWithKeyboard != null && Interactable.interactingWithKeyboard != interactable){
          Interactable.interactingWithKeyboard.onMousePressedOutsideWhileInteractingWithKeyboard();
        }
        Interactable.pressed = interactable;
        interactable.onMousePressed(x - interactable.getLeft(), y - interactable.getTop());
        return true;
      }
      return false;
    }
  }
  final public static void mouseDragged(float x, float y){
    synchronized(Interactable.instances){
      if(Interactable.pressed == null) return;
      Interactable.pressed.onMouseDragged(x - Interactable.pressed.getLeft(), y - Interactable.pressed.getTop());
    }
  }
  final public static void mouseReleased(){
    synchronized(Interactable.instances){
      if(Interactable.pressed == null) return;
      Interactable pressed = Interactable.pressed;
      Interactable.pressed = null;
      pressed.onMouseReleased();
    }
  }
  final public static void mouseMoved(float x, float y){
    synchronized(Interactable.instances){
      for(int i = Interactable.instances.size() - 1; i >= 0; i --){
        Interactable interactable = Interactable.instances.get(i);
        if(!interactable.isActive || !interactable.isPointInside(x, y)) continue;
        interactable.onMouseMoved(x - interactable.getLeft(), y - interactable.getTop());
        break;
      }
    }
  }
  final public static int hoverMouseIcon(float x, float y){
    synchronized(Interactable.instances){
      for(int i = Interactable.instances.size() - 1; i >= 0; i --){
        Interactable interactable = Interactable.instances.get(i);
        if(!interactable.isActive || !interactable.isPointInside(x, y)) continue;
        return interactable.getHoverCursorIcon(x - interactable.getLeft(), y - interactable.getTop());
      }
      return Cursor.ARROW;
    }
  }
  final public static void clearInteractingWithKeyboard(){
    if(Interactable.interactingWithKeyboard == null) return;
    Interactable.interactingWithKeyboard.endInteractingWithKeyboard();
  }
  final public static Interactable getInteractingWithKeyboard(){
    return Interactable.interactingWithKeyboard;
  }
  final public static void keyPressed(char key, int keyCode){
    if(Interactable.interactingWithKeyboard == null) return;
    Interactable.interactingWithKeyboard.onKeyPressed(key, keyCode);
  }
  final public static void keyReleased(char key, int keyCode){
    if(Interactable.interactingWithKeyboard == null) return;
    Interactable.interactingWithKeyboard.onKeyReleased(key, keyCode);
  }
  final public static void draw(PGraphics pg){
    if(pg == null) return;
    synchronized(Interactable.instances){
      for(Interactable i:Interactable.instances){
        if(!i.isActive) return;
        i.onUpdate();
        i.onDraw(pg);
      }
    }
  }
  
  
  final public String getName(){
    return this.name;
  }
  final public Interactable setName(String name){
    this.name = name == null ? "" : name;
    return this;
  }
  
  final public boolean isActive(){
    return this.isActive();
  }
  final public Interactable setActive(boolean isActive){
    this.isActive = isActive;
    if(!this.isActive){
      this.interuptPressed();
      this.interuptInteractingWithKeyboard();
    }
    return this;
  }
  
  final public boolean isPressed(){
    return Interactable.pressed == this;
  }
  final public boolean isInteractingWithKeyboard(){
    return Interactable.interactingWithKeyboard == this;
  }
  final public Interactable interuptPressed(){
    if(!this.isActive || this.isDestroyed) return this;
    if(Interactable.pressed != this) return this;
    Interactable.pressed = null;
    this.onPressedInterupted();
    return this;
  }
  final public Interactable startInteractingWithKeyboard(){
    if(!this.isActive || this.isDestroyed) return this;
    if(Interactable.interactingWithKeyboard == this) return this;
    if(Interactable.interactingWithKeyboard != null) Interactable.interactingWithKeyboard.endInteractingWithKeyboard();
    Interactable.interactingWithKeyboard = this;
    this.onInteractionWithKeyboardStarted();
    return this;
  }
  final public Interactable endInteractingWithKeyboard(){
    if(Interactable.interactingWithKeyboard != this) return this;
    Interactable.interactingWithKeyboard = null;
    this.onInteractionWithKeyboardEnded();
    return this;
  }
  final public Interactable interuptInteractingWithKeyboard(){
    if(Interactable.interactingWithKeyboard != this) return this;
    Interactable.interactingWithKeyboard = null;
    this.onInteractionWithKeyboardInterupted();
    return this;
  }
  abstract protected void onMousePressed(float x, float y);
  abstract protected void onMouseDragged(float x, float y);
  abstract protected void onMouseReleased();
  abstract protected void onMouseMoved(float x, float y);
  abstract protected void onPressedInterupted();
  abstract protected void onKeyPressed(char key, int keyCode);
  abstract protected void onKeyReleased(char key, int keyCode);
  abstract protected void onInteractionWithKeyboardStarted();
  abstract protected void onInteractionWithKeyboardEnded();
  abstract protected void onInteractionWithKeyboardInterupted();
  abstract protected void onMousePressedOutsideWhileInteractingWithKeyboard();
  abstract protected int getHoverCursorIcon(float x, float y);
  abstract protected void onUpdate();
  abstract protected void onDraw(PGraphics pg);
}
static public class Layout{
  static public PApplet applet;
  final static public float buttonLayerHeight = 0.4f;
  
  static public Button[][] imageButtons;
  static public Button imageButton;
  
  static public TextField rowIndexText, columnIndexText;
  static public TextField maxDigitsText;
  static public Slider maxDigitsSlider;
  static public TextField alignmentText;
  static public Button alignLeftButton, alignRightButton;
  static public TextField colorText;
  static public ColorButton colorButton;
  static public TextField numberText, numberField;
  static public Button generateText, saveText;
  static public Slider saveSizeSlider;
  static public Button saveResolutionButton;
  static public Button addLeft, addAbove, addRight, addBelow, removeRow, removeColumn;
  static public Button sortButton;
  
  static public void clear(){
    Interactable.clear();
  }
  static public void generateLayout(){
    Layout.generateLayout(Layout.applet);
  }
  static public void generateLayout(PApplet applet){
    if(applet == null) return;
    Layout.generateLayout(applet.width, applet.height);
  }
  static public void generateLayout(int width, int height){
    Interactable.clear();
    float buttonsTop = height * (1 - Layout.buttonLayerHeight);
    Layout.generateImageInteractables(width, height);
    Layout.generateInformationInteractables(width, height);
  }
  
  static public void clearImageInteractables(){
    if(Layout.imageButtons != null){
      for(int row = 0; row < Layout.imageButtons.length; row ++){
        for(int column = 0; column < Layout.imageButtons[row].length; column ++){
          Layout.imageButtons[row][column].destroy();
          Layout.imageButtons[row][column] = null;
        }
      }
      Layout.imageButtons = null;
    }
    if(Layout.imageButton != null){
      Layout.imageButton.destroy();
      Layout.imageButton = null;
    }
  }
  static public void generateImageInteractables(){
    Layout.generateImageInteractables(Layout.applet);
  }
  static public void generateImageInteractables(PApplet applet){
    if(applet == null) return;
    Layout.generateImageInteractables(applet.width, applet.height);
  }
  static public void generateImageInteractables(int width, int height){
    Layout.clearImageInteractables();
    float buttonsTop = height * (1 - Layout.buttonLayerHeight);
    
    float appropriateScale = Global.generator.getAppropriateScale(width, buttonsTop);
    float imageWidth = Global.generator.getGraphicsWidth(appropriateScale);
    float imageHeight = Global.generator.getGraphicsHeight(appropriateScale);
    float imageLeft = width / 2 - imageWidth / 2;
    float imageTop = buttonsTop / 2 - imageHeight / 2;
    
    //imageLeft = 0;
    //imageTop = 0;
    
    float[][] columnBorders = Global.generator.getAllColumnBorders(appropriateScale);
    float[][] rowBorders = Global.generator.getAllRowBorders(appropriateScale);
    
    //Layout.imageButton = new Button(imageLeft, imageTop, imageLeft + imageWidth, imageTop + imageHeight, "image", "", 0x00000000){
    Layout.imageButton = new Button(0, 0, width, buttonsTop, "image", "", 0x00000000, PConstants.CENTER){
      protected void action(){
        Global.selectedRow = -1;
        Global.selectedColumn = -1;
        Layout.clear();
        Layout.generateLayout();
      }
    };
    Layout.imageButtons = new Button[rowBorders.length][columnBorders.length];
    for(int row = 0; row < rowBorders.length; row ++){
      for(int column = 0; column < columnBorders.length; column ++){
        float left = imageLeft + columnBorders[column][0];
        float right = imageLeft + columnBorders[column][1];
        float top = imageTop + rowBorders[row][0];
        float bottom = imageTop + rowBorders[row][1];
        Layout.imageButtons[row][column] = new GeneratorButton(left, top, right, bottom, row, column);
      }
    }
  }
  
  static public void clearInformationInteractables(){
    
  }
  static public void generateInformationInteractables(){
    Layout.generateInformationInteractables(Layout.applet);
  }
  static public void generateInformationInteractables(PApplet applet){
    if(applet == null) return;
    Layout.generateInformationInteractables(applet.width, applet.height);
  }
  static public void generateInformationInteractables(int width, int height){
    Layout.clearInformationInteractables();
    float buttonsTop = height * (1 - Layout.buttonLayerHeight);
    float buttonsHeight = height * Layout.buttonLayerHeight;
    
    float borderSize = buttonsHeight * 0.1f;
    
    float[] xs = new float[13];
    for(int i = 0; i < xs.length; i ++){
      xs[i] = borderSize + (width - borderSize * 2) * i / (xs.length - 1);
    }
    float[] ys = new float[13];
    for(int i = 0; i < ys.length; i ++){
      ys[i] = buttonsTop + borderSize + (buttonsHeight - borderSize * 2) * i / (ys.length - 1);
    }
    
    if(Global.selectedRow >= 0 && Global.selectedColumn >= 0){
      Layout.rowIndexText = new TextField(xs[0], ys[0], xs[3], ys[1], "rowdisplay", "Row: " + Global.selectedRow, false, 0xFFFFFFFF, 0xFFFFFFFF){
        protected void onUpdate(){
          this.setDefaultText("Řádek: " + Global.selectedRow);
        }
        protected boolean isValidCharacter(char character){return true;}
        protected void onTextChanged(){}
      };
      Layout.columnIndexText = new TextField(xs[0], ys[1], xs[3], ys[2], "columndisplay", "Column: " + Global.selectedColumn, false, 0xFFFFFFFF, 0xFFFFFFFF){
        protected void onUpdate(){
          this.setDefaultText("Sloupec: " + Global.selectedColumn);
        }
        protected boolean isValidCharacter(char character){return true;}
        protected void onTextChanged(){}
      };
      Layout.maxDigitsText = new TextField(xs[0], ys[3], xs[4], ys[4], "maxdigitstext", "Max digits: " + Global.generator.getColumnSize(Global.selectedColumn), false, 0xFFFFFFFF, 0xFFFFFFFF){
        protected void onUpdate(){
          this.setDefaultText("Maximální počet cifer: " + Global.generator.getColumnSize(Global.selectedColumn));
        }
        protected boolean isValidCharacter(char character){return true;}
        protected void onTextChanged(){}
      };
      Layout.maxDigitsSlider = new Slider(xs[4], ys[3], xs[8], ys[4], "maxdigitsslider", Global.generator.getColumnSize(Global.selectedColumn), 1, 32, 0.25f, 0x00000000, 0xFFFFFFFF, 0x7FFFFFFF, 0xFFFFFFFF){
        protected String getDisplayString(float value){
          return (int)Math.round(value) + "";
        }
        protected void onValueChanged(){
          int value = (int)Math.round(this.getGlobalValue());
          if(value == Global.generator.getColumnSize(Global.selectedColumn)) return;
          Global.generator.setColumnSize(Global.selectedColumn, value, true);
          Layout.generateImageInteractables();
        }
      };
      Layout.alignmentText = new TextField(xs[0], ys[4], xs[4], ys[5], "aligntext", "Aligned: " + (Global.generator.isColumnAlignedLeft(Global.selectedColumn) ? "Left" : "Right"), false, 0xFFFFFFFF, 0xFFFFFFFF){
        protected void onUpdate(){
          this.setDefaultText("Zarovnání: " + (Global.generator.isColumnAlignedLeft(Global.selectedColumn) ? "Doleva" : "Doprava"));
        }
        protected boolean isValidCharacter(char character){return true;}
        protected void onTextChanged(){}
      };
      Layout.alignLeftButton = new Button(xs[4], ys[4], xs[6], ys[5], "alignleftbutton", "| <-", 0xFFFFFFFF, PConstants.CENTER){
        protected void action(){
          Global.generator.setColumnAlign(Global.selectedColumn, true);
        }
        protected void onUpdate(){
          if(Global.generator.isColumnAlignedLeft(Global.selectedColumn)) this.setColor(0xFFFFFFFF);
          else this.setColor(0xFF7F7F7F);
        }
        protected void onDraw(PGraphics pg){
          pg.pushMatrix();
          pg.translate(0, this.getHeight() * 0.05f);
          super.onDraw(pg);
          pg.popMatrix();
        }
      };
      Layout.alignRightButton = new Button(xs[6], ys[4], xs[8], ys[5], "alignrightbutton", "-> |", 0xFFFFFFFF, PConstants.CENTER){
        protected void action(){
          Global.generator.setColumnAlign(Global.selectedColumn, false);
        }
        protected void onUpdate(){
          if(Global.generator.isColumnAlignedRight(Global.selectedColumn)) this.setColor(0xFFFFFFFF);
          else this.setColor(0xFF7F7F7F);
        }
        protected void onDraw(PGraphics pg){
          pg.pushMatrix();
          pg.translate(0, this.getHeight() * 0.05f);
          super.onDraw(pg);
          pg.popMatrix();
        }
      };
      Layout.colorText = new TextField(xs[0], ys[5], xs[4], ys[6], "aligntext", "Aligned: " + (Global.generator.isColumnAlignedLeft(Global.selectedColumn) ? "Left" : "Right"), false, 0xFFFFFFFF, 0xFFFFFFFF){
        protected void onUpdate(){
          this.setDefaultText("Barva: ");
        }
        protected boolean isValidCharacter(char character){return true;}
        protected void onTextChanged(){}
      };
      Layout.colorButton = new ColorButton(xs[4], ys[5], xs[8], ys[6], "colorselector");
      Layout.numberText = new TextField(xs[0], ys[7], xs[4], ys[8], "numbertext", "Číslo", false, 0xFFFFFFFF, 0xFFFFFFFF){
        protected void onTextChanged(){}
        protected boolean isValidCharacter(char key){return true;}
      };
      Layout.numberField = new TextField(xs[4], ys[7], xs[8], ys[8], "numberinput", "Číslo", true, 0xFFFFFFFF, 0xFF7F7F7F){
        protected void onTextChanged(){
          if(Global.selectedRow < 0 || Global.selectedColumn < 0) return;
          Global.generator.setString(Global.selectedRow, Global.selectedColumn, this.getCurrentText());
          
        }
        protected void onUpdate(){
          if(Global.selectedRow < 0 || Global.selectedColumn < 0) return;
          this.setTextColor(Global.generator.getRowColor(Global.selectedRow));
          this.setCurrentText(Global.generator.getString(Global.selectedRow, Global.selectedColumn));
        }
        protected boolean isValidCharacter(char key){
          return Character.isDigit(key);
        }
      };
      Layout.addLeft = new Button(xs[0], ys[9], xs[3], ys[10], "addleftbutton", "Přidat sloupec vlevo", 0xFFFFFFFF, PConstants.RIGHT){
        protected void action(){
          Global.generator.addRandomColumn(Global.selectedColumn);
          Layout.generateLayout();
        }
      };
      Layout.addRight = new Button(xs[3], ys[9], xs[6], ys[10], "addleftbutton", "Přidat sloupec vpravo", 0xFFFFFFFF, PConstants.RIGHT){
        protected void action(){
          Global.generator.addRandomColumn(Global.selectedColumn + 1);
          Global.selectedColumn ++;
          Layout.generateLayout();
        }
      };
      Layout.addAbove = new Button(xs[6], ys[9], xs[9], ys[10], "addleftbutton", "Přidat řádek nad", 0xFFFFFFFF, PConstants.RIGHT){
        protected void action(){
          Global.generator.addRandomRow(Global.selectedRow);
          Layout.generateLayout();
        }
      };
      Layout.addBelow = new Button(xs[9], ys[9], xs[12], ys[10], "addleftbutton", "Přidat řádek pod", 0xFFFFFFFF, PConstants.RIGHT){
        protected void action(){
          Global.generator.addRandomColumn(Global.selectedRow + 1);
          Global.selectedRow ++;
          Layout.generateLayout();
        }
      };
      Layout.removeRow = new Button(xs[0], ys[10], xs[3], ys[11], "removerowbutton", "Odebrat řádek", 0xFFFFFFFF, PConstants.RIGHT){
        protected void action(){
          Global.generator.removeRow(Global.selectedRow);
          Global.selectedRow --;
          Layout.generateLayout();
        }
      };
      Layout.removeColumn = new Button(xs[3], ys[10], xs[6], ys[11], "removerowbutton", "Odebrat sloupec", 0xFFFFFFFF, PConstants.RIGHT){
        protected void action(){
          Global.generator.removeColumn(Global.selectedColumn);
          Global.selectedColumn --;
          Layout.generateLayout();
        }
      };
    }
    Layout.generateText = new Button(xs[9], ys[0], xs[12], ys[1], "generatebutton", "Generovat náhodný", 0xFFFFFFFF, PConstants.RIGHT){
      protected void action(){
        Global.recreateGenerator();
        Layout.generateLayout();
      }
    };
    Layout.saveText = new Button(xs[9], ys[2], xs[12], ys[3], "savebutton", "Uložit jako...", 0xFFFFFFFF, PConstants.RIGHT){
      protected void onUpdate(){
        if(System.currentTimeMillis() - Global.lastSaved < 3000){
          float perc = (System.currentTimeMillis() - Global.lastSaved) / 3000.0f;
          if(Global.saveState == 1){
            this.setColor(Layout.applet.lerpColor(0xFFFF1F1F, 0xFFFFFFFF, perc * perc));
            this.setText("Chyba ukládání!");
          }
          else if(Global.saveState == 2){
            this.setColor(Layout.applet.lerpColor(0xFFBFBF1F, 0xFFFFFFFF, perc * perc));
            this.setText("Ukládání zrušeno.");
          }
          else{
            this.setColor(Layout.applet.lerpColor(0xFF1FFF1F, 0xFFFFFFFF, perc * perc));
            this.setText("Uloženo jako: \"" + Global.lastSaveFile + "\"");
          }
        }
        else{
          this.setColor(0xFFFFFFFF);
          this.setText("Uložit jako...");
        }
      }
      protected void action(){
        Global.save();
      }
    };
    Layout.saveResolutionButton = new Button(xs[9], ys[3], xs[12], ys[4] - (ys[1] - ys[0]) * 0.05f, "resolutiontextbutton", "Resolution", 0xFFFFFFFF, PConstants.RIGHT){
      protected void onUpdate(){
        int width = (int)Global.generator.getGraphicsWidth(Global.outputScale);
        int height = (int)Global.generator.getGraphicsHeight(Global.outputScale);
        this.setText(width + "x" + height);
      }
      protected void action(){}
    };
    Layout.saveSizeSlider = new Slider(xs[9], ys[4], xs[12], ys[5], "savesizeslider", Global.outputScale, 10, 200, 0.2f, 0x00000000, 0xFFFFFFFF, 0x7FFFFFFF, 0xFFFFFFFF){
      protected void onValueChanged(){
        Global.outputScale = (int)Math.round(this.getGlobalValue());
      }
      protected String getDisplayString(float value){
        return "";
      }
    };
    Layout.saveResolutionButton = new Button(xs[9], ys[6], xs[12], ys[7], "loadfongbutton", "Zvolit font", 0xFFFFFFFF, PConstants.RIGHT){
      protected void onDraw(PGraphics pg){
        if(Global.font != null) pg.textFont(Global.font);
        super.onDraw(pg);
      }
      protected void onUpdate(){
        if(Global.font == null) this.setText("Zvolit font...");
        else this.setText("Font: " + Global.font.getName());
      }
      protected void action(){
        Global.loadFont();
      }
    };
    Layout.sortButton = new Button(xs[0], ys[11], xs[3], ys[12], "sortbutton", "Seřadit podle barvy", 0xFFFFFFFF, PConstants.RIGHT){
      protected void action(){
        Global.generator.sortByColor();
        Global.selectedRow = -1;
        Layout.generateLayout();
      }
    };
  }
  
  final static public class GeneratorButton extends Button{
    final public int row, column;
    
    public GeneratorButton(float x1, float y1, float x2, float y2, int row, int column){
      super(x1, y1, x2, y2, "generatorbuttonr" + row + "c" + column, "", 0x00000000, PConstants.CENTER);
      this.row = row;
      this.column = column;
    }
    
    protected void onDraw(PGraphics pg){
      super.onDraw(pg);
      if(this.row == Global.selectedRow && this.column == Global.selectedColumn){
        pg.noFill();
        pg.strokeWeight(2);
        pg.stroke(255);
        pg.rectMode(CORNERS);
        pg.rect(this.getLeft(), this.getTop(), this.getRight(), this.getBottom());
      }
    }
    
    protected void action(){
      Global.selectedRow = this.row;
      Global.selectedColumn = this.column;
      Layout.clear();
      Layout.generateLayout();
    }
  }
  
  final static public class ColorButton extends Interactable{
    static final public float colorPickedHeight = 0.2f;
    public ColorButton(float x1, float y1, float x2, float y2, String name){
      super(x1, y1, x2, y2, name);
    }
    
    final protected void onMousePressed(float x, float y){
      if(Global.selectedRow < 0 || Global.selectedColumn < 0) return;
      if(x < this.getHeight() * ColorButton.colorPickedHeight) return;
      int[] colors = Generator.getAllColors();
      int index = (int)Math.min(colors.length - 1, x * colors.length / this.getWidth());
      Global.generator.setRowColorIndex(Global.selectedRow, index);
    }
    final protected void onMouseDragged(float x, float y){
      if(Global.selectedRow < 0 || Global.selectedColumn < 0) return;
      if(x < this.getHeight() * ColorButton.colorPickedHeight) return;
      int[] colors = Generator.getAllColors();
      int index = (int)Math.min(colors.length - 1, Math.max(0, x * colors.length / this.getWidth()));
      Global.generator.setRowColorIndex(Global.selectedRow, index);
    }
    final protected void onMouseReleased(){}
    final protected void onMouseMoved(float x, float y){}
    final protected void onPressedInterupted(){}
    final protected void onKeyPressed(char key, int keyCode){}
    final protected void onKeyReleased(char key, int keyCode){}
    final protected void onInteractionWithKeyboardStarted(){}
    final protected void onInteractionWithKeyboardEnded(){}
    final protected void onInteractionWithKeyboardInterupted(){}
    final protected void onMousePressedOutsideWhileInteractingWithKeyboard(){}
    final protected int getHoverCursorIcon(float x, float y){return Interactable.Cursor.HAND;}
    final protected void onUpdate(){}
    final protected void onDraw(PGraphics pg){
      if(Global.selectedRow < 0 || Global.selectedColumn < 0) return;
      int colorIndex = Global.generator.getRowColorIndex(Global.selectedRow);
      int[] colors = Generator.getAllColors();
      
      float left = this.getLeft();
      float right = this.getRight();
      float top = this.getTop();
      float bottom = this.getBottom();
      float width = right - left;
      float height = bottom - top;
      
      pg.noStroke();
      pg.fill(colors[colorIndex]);
      pg.rectMode(CORNERS);
      
      pg.rect(left, top, right, top + height * ColorButton.colorPickedHeight);
      
      for(int i = 0; i < colors.length; i ++){
        pg.fill(colors[i]);
        pg.rect(left + width * i / colors.length, top + height * ColorButton.colorPickedHeight, left + width * (i + 1) / colors.length, bottom);
      }
    }
  }
}
static class Rect{
  float x1, y1, x2, y2;
  
  public Rect(float x1, float y1, float x2, float y2){
    this.x1 = x1;
    this.y1 = y1;
    this.x2 = x2;
    this.y2 = y2;
  }
  
  public Rect translate(float x, float y){
    this.x1 += x;
    this.y1 += y;
    this.x2 += x;
    this.y2 += y;
    return this;
  }
  
  final public Rect set(float x1, float y1, float x2, float y2){
    this.x1 = x1;
    this.y1 = y1;
    this.x2 = x2;
    this.y2 = y2;
    return this;
  }
  final public float getLeft(){
    return (float)Math.min(this.x1, this.x2);
  }
  final public float getRight(){
    return (float)Math.max(this.x1, this.x2);
  }
  final public float getTop(){
    return (float)Math.min(this.y1, this.y2);
  }
  final public float getBottom(){
    return (float)Math.max(this.y1, this.y2);
  }
  final public float getCenterX(){
    return (this.x1 + this.x2) * 0.5f;
  }
  final public float getCenterY(){
    return (this.y1 + this.y2) * 0.5f;
  }
  final public float getWidth(){
    return (float)Math.abs(this.x1 - this.x2);
  }
  final public float getHeight(){
    return (float)Math.abs(this.y1 - this.y2);
  }
  
  final public boolean isPointInside(float x, float y){
    float left = this.getLeft();
    float right = this.getRight();
    float top = this.getTop();
    float bottom = this.getBottom();
    return x >= left && x <= right && y >= top && y <= bottom;
  }
  
  
}
abstract static public class Slider extends Interactable{
  private int backgroundColor, foregroundColor, handleColor, textColor;
  private float min, max, value;
  private float handleSize;
  
  private float lastMouseX, lastMouseY;
  
  public Slider(float x1, float y1, float x2, float y2, String name, float value, float min, float max, float handleSize, int backgroundColor, int foregroundColor, int handleColor, int textColor){
    super(x1, y1, x2, y2, name);
    this.setRange(min, max).setGlobalValue(value).setHandleSize(handleSize);
    this.setBackgroundColor(backgroundColor).setForegroundColor(foregroundColor);
    this.setHandleColor(handleColor).setTextColor(textColor);
  }
  
  final public int getBackgroundColor(){
    return this.backgroundColor;
  }
  final public Slider setBackgroundColor(int col){
    this.backgroundColor = col;
    return this;
  }
  final public int getHandleColor(){
    return this.handleColor;
  }
  final public Slider setHandleColor(int col){
    this.handleColor = col;
    return this;
  }
  final public int getTextColor(){
    return this.textColor;
  }
  final public Slider setTextColor(int col){
    this.textColor = col;
    return this;
  }
  final public int getForegroundColor(){
    return this.backgroundColor;
  }
  final public Slider setForegroundColor(int col){
    this.foregroundColor = col;
    return this;
  }
  final public float getHandleSize(){
    return this.handleSize;
  }
  final public Slider setHandleSize(float handleSize){
    this.handleSize = (float)Math.min(0.5f, Math.max(0, handleSize));
    return this;
  }
  
  final public float getMinimum(){
    return this.min;
  }
  final public float getMaximum(){
    return this.max;
  }
  final public Slider setMinimum(float min){
    this.min = min > this.max ? this.max : min;
    return this;
  }
  final public Slider setMaximum(float max){
    this.max = max > this.min ? this.min : max;
    return this;
  }
  final public Slider setRange(float min, float max){
    if(min > max){
      float temp = min;
      max = min;
      min = temp;
    }
    this.min = min;
    this.max = max;
    return this;
  }
  final public float getLocalValue(){
    return this.value;
  }
  final public float getGlobalValue(){
    return this.min + (this.max - this.min) * this.value;
  }
  final public Slider setLocalValue(float value){
    value = (float)Math.min(1, Math.max(0, value));
    if(value == this.value) return this;
    this.value = value;
    this.onValueChanged();
    return this;
  }
  final public Slider setGlobalValue(float value){
    if(this.max - this.min == 0){
      this.value = 0;
      return this;
    }
    value = (float)Math.min(this.max, Math.max(this.min, value));
    value = (value - this.min) / (this.max - this.min);
    if(value == this.value) return this;
    this.value = value;
    this.onValueChanged();
    return this;
  }
  
  final public Rect getHandleLocalRect(){
    if(this.getWidth() > this.getHeight()){
      float handleSize = this.handleSize * this.getWidth();
      float handleMin = handleSize * 0.5f;
      float handleMax = this.getWidth() - handleSize * 0.5f;
      float handleCenter = handleMin + (handleMax - handleMin) * this.value;
      float handleLeft = handleCenter - handleSize * 0.5f;
      float handleRight = handleCenter + handleSize * 0.5f;
      return new Rect(handleLeft, 0, handleRight, this.getHeight());
    }
    else{
      float handleSize = this.handleSize * this.getHeight();
      float handleMin = handleSize * 0.5f;
      float handleMax = this.getHeight() - handleSize * 0.5f;
      float handleCenter = handleMin + (handleMax - handleMin) * this.value;
      float handleTop = handleCenter - handleSize * 0.5f;
      float handleBottom = handleCenter + handleSize * 0.5f;
      return new Rect(0, handleTop, this.getWidth(), handleBottom);
    }    
  }
  final public Rect getHandleGlobalRect(){
    return this.getHandleLocalRect().translate(this.getLeft(), this.getTop());
  }
  final protected void onMousePressed(float x, float y){
    if(this.getWidth() > this.getHeight()){
      float handleSize = this.handleSize * this.getWidth();
      float handleMin = handleSize * 0.5f;
      float handleMax = this.getWidth() - handleSize * 0.5f;
      float handleCenter = handleMin + (handleMax - handleMin) * this.value;
      float handleLeft = handleCenter - handleSize * 0.5f;
      float handleRight = handleCenter + handleSize * 0.5f;
      if(x < handleLeft || x > handleRight) this.setLocalValue((x - handleMin) / (handleMax - handleMin));
      this.lastMouseX = (float)Math.min(handleMax, Math.max(handleMin, x));
      this.lastMouseY = y;
    }
    else{
      float handleSize = this.handleSize * this.getHeight();
      float handleMin = handleSize * 0.5f;
      float handleMax = this.getHeight() - handleSize * 0.5f;
      float handleCenter = handleMin + (handleMax - handleMin) * this.value;
      float handleTop = handleCenter - handleSize * 0.5f;
      float handleBottom = handleCenter + handleSize * 0.5f;
      if(x < handleTop || x > handleBottom) this.setLocalValue((y - handleMin) / (handleMax - handleMin));
      this.lastMouseX = x;
      this.lastMouseY = (float)Math.min(handleMax, Math.max(handleMin, y));
    }
  }
  final protected void onMouseDragged(float x, float y){
    if(this.getWidth() > this.getHeight()){
      float handleSize = this.handleSize * this.getWidth();
      float handleMin = handleSize * 0.5f;
      float handleMax = this.getWidth() - handleSize * 0.5f;
      float deltaMouse = x - this.lastMouseX;
      float deltaValue = deltaMouse / (handleMax - handleMin);
      this.setLocalValue(this.value + deltaValue);
      this.lastMouseX = (float)Math.min(handleMax, Math.max(handleMin, x));
      this.lastMouseY = y;
    }
    else{
      float handleSize = this.handleSize * this.getHeight();
      float handleMin = handleSize * 0.5f;
      float handleMax = this.getHeight() - handleSize * 0.5f;
      float deltaMouse = y - this.lastMouseY;
      float deltaValue = deltaMouse / (handleMax - handleMin);
      this.setLocalValue(this.value + deltaValue);
      this.lastMouseX = x;
      this.lastMouseY = (float)Math.min(handleMax, Math.max(handleMin, y));
    }
  }
  final protected void onMouseReleased(){}
  final protected void onMouseMoved(float x, float y){}
  final protected void onPressedInterupted(){}
  final protected void onKeyPressed(char key, int keyCode){}
  final protected void onKeyReleased(char key, int keyCode){}
  final protected void onInteractionWithKeyboardStarted(){}
  final protected void onInteractionWithKeyboardEnded(){}
  final protected void onInteractionWithKeyboardInterupted(){}
  final protected void onMousePressedOutsideWhileInteractingWithKeyboard(){}
  final protected int getHoverCursorIcon(float x, float y){
    return Interactable.Cursor.HAND;
  }
  protected void onUpdate(){}
  final protected void onDraw(PGraphics pg){
    if(this.getWidth() < 1 || this.getHeight() < 1) return;
    
    float left = this.getLeft();
    float right = this.getRight();
    float top = this.getTop();
    float bottom = this.getBottom();
    
    Rect handleRect = this.getHandleGlobalRect();
    float handleLeft = handleRect.getLeft();
    float handleRight = handleRect.getRight();
    float handleTop = handleRect.getTop();
    float handleBottom = handleRect.getBottom();
    
    pg.rectMode(CORNERS);
    
    pg.fill(this.backgroundColor, (this.backgroundColor >> 24) & 0xFF);
    pg.noStroke();
    pg.rect(left, top, right, bottom);
    
    pg.fill(this.handleColor, (this.handleColor >> 24) & 0xFF);
    pg.rect(handleLeft, handleTop, handleRight, handleBottom);
    
    String text = this.getDisplayString(this.getGlobalValue());
    text = text == null ? "" : text;
    pg.textSize(10);
    float textWidth = pg.textWidth(text) * 0.1f;
    float textSize = (float)Math.min(handleRect.getWidth() / textWidth, handleRect.getHeight()) * 0.8f;
    pg.textSize(textSize);
    pg.textAlign(PConstants.CENTER, PConstants.CENTER);
    pg.fill(this.textColor, (this.textColor >> 24) & 0xFF);
    pg.text(text, handleRect.getCenterX(), handleRect.getCenterY());
    
    pg.noFill();
    pg.stroke(this.foregroundColor, (this.foregroundColor >> 24) & 0xFF);
    pg.strokeWeight(1);
    pg.rect(left, top, right, bottom);
  }
  
  abstract protected void onValueChanged();
  abstract protected String getDisplayString(float value);
}
abstract static public class TextField extends Interactable{
  public final boolean isWritable;
  private String defaultText;
  private String currentText;
  private int textColor, defaultTextColor;
  
  public TextField(float x1, float y1, float x2, float y2, String name, String defaultText, boolean isWritable, int textColor, int defaultTextColor){
    super(x1, y1, x2, y2, name);
    this.defaultText = defaultText == null ? "" : defaultText;
    this.isWritable = isWritable;
    this.currentText = "";
    this.textColor = textColor;
    this.defaultTextColor = defaultTextColor;
  }
  
  final public String getDefaultText(){
    return this.defaultText;
  }
  final public TextField setDefaultText(String text){
    this.defaultText = text == null ? "" : text;
    return this;
  }
  final public String getCurrentText(){
    return this.currentText;
  }
  final public TextField setCurrentText(String text){
    if(!this.isWritable) return this;
    this.currentText = text == null ? "" : text;
    return this;
  }
  final public int getTextColor(){
    return this.textColor;
  }
  final public TextField setTextColor(int col){
    this.textColor = col;
    return this;
  }
  final public int getDefaultTextColor(){
    return this.defaultTextColor;
  }
  final public TextField setDefaultTextColor(int col){
    this.defaultTextColor = col;
    return this;
  }
  
  final protected void onMousePressed(float x, float y){
    if(this.isWritable) this.startInteractingWithKeyboard();
  }
  final protected void onMouseDragged(float x, float y){}
  final protected void onMouseReleased(){}
  final protected void onMouseMoved(float x, float y){}
  final protected void onPressedInterupted(){}
  final protected void onKeyPressed(char key, int keyCode){
    if(key == PConstants.ESC || key == PConstants.ENTER){
      this.endInteractingWithKeyboard();
    }
    else if(key == PConstants.BACKSPACE || keyCode == 67){
      if(this.currentText.length() > 0){
        this.currentText = this.currentText.substring(0, this.currentText.length() - 1);
        this.onTextChanged();
      }
    }
    else if(this.isValidCharacter(key)){
      this.currentText += key;
      this.onTextChanged();
    }
  }
  final protected void onKeyReleased(char key, int keyCode){}
  final protected void onInteractionWithKeyboardStarted(){}
  final protected void onInteractionWithKeyboardEnded(){}
  final protected void onInteractionWithKeyboardInterupted(){}
  final protected void onMousePressedOutsideWhileInteractingWithKeyboard(){
    this.endInteractingWithKeyboard();
  }
  final protected int getHoverCursorIcon(float x, float y){
    return Interactable.Cursor.TEXT;
  }
  protected void onUpdate(){}
  final protected void onDraw(PGraphics pg){
    int textColor = 0;
    if(!this.isWritable || this.currentText.length() > 0) textColor = this.textColor;
    else textColor = this.defaultTextColor;
    pg.fill(textColor, (textColor >> 24) & 0xFF);
    String string = this.currentText.length() == 0 ? this.defaultText : this.currentText;
    
    pg.textSize(10);
    float textWidth = pg.textWidth(string) * 0.1f;
    float textSize = (float)Math.min(this.getWidth() / textWidth, this.getHeight());
    pg.textSize(textSize);
    pg.textAlign(PConstants.LEFT, PConstants.BOTTOM);
    pg.text(string, this.getLeft(), this.getBottom() - textSize * 0.05f);
    
    if(this.isInteractingWithKeyboard()){
      pg.stroke(textColor);
      pg.line(this.getLeft(), this.getBottom(), this.getRight(), this.getBottom());
    }
  }
  
  abstract protected boolean isValidCharacter(char key);
  abstract protected void onTextChanged();
}
  public void settings() {  size(640, 480); }
  static public void main(String[] passedArgs) {
    String[] appletArgs = new String[] { "RndNumTestB" };
    if (passedArgs != null) {
      PApplet.main(concat(appletArgs, passedArgs));
    } else {
      PApplet.main(appletArgs);
    }
  }
}

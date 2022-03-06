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
    float textWidth = pg.textWidth(string) * 0.1;
    float textSize = (float)Math.min(this.getWidth() / textWidth, this.getHeight());
    pg.textSize(textSize);
    pg.textAlign(PConstants.LEFT, PConstants.BOTTOM);
    pg.text(string, this.getLeft(), this.getBottom() - textSize * 0.05);
    
    if(this.isInteractingWithKeyboard()){
      pg.stroke(textColor);
      pg.line(this.getLeft(), this.getBottom(), this.getRight(), this.getBottom());
    }
  }
  
  abstract protected boolean isValidCharacter(char key);
  abstract protected void onTextChanged();
}
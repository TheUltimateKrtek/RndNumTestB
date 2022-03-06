abstract static public class Button extends Interactable{
    private String text;
    private int col;
    private int align;
    
    public Button(float x1, float y1, float x2, float y2, String name, String text, int col, int align) {
        super(x1, y1, x2, y2, name);
        this.text = text;
        this.col = col;
        this.align = align;
    }
    
    final public String getText() {
        return this.text;
    }
    final public Button setText(String text) {
        this.text = text == null ? "" : text;
        return this;
    }
    
    final public int getColor() {
        return this.col;
    }
    final public Button setColor(int col) {
        this.col = col;
        return this;
    }
    
    final public int getAlign() {
        return this.align;
    }
    final public Button setAlign(int align) {
        this.align = align;
        return this;
    }
    
    final protected void onMousePressed(float x, float y) {}
    final protected void onMouseDragged(float x, float y) {}
    final protected void onMouseReleased() {this.action();}
    final protected void onMouseMoved(float x, float y) {}
    final protected void onPressedInterupted() {}
    final protected void onKeyPressed(char key, int keyCode) {}
    final protected void onKeyReleased(char key, int keyCode) {}
    final protected void onInteractionWithKeyboardStarted() {}
    final protected void onInteractionWithKeyboardEnded() {}
    final protected void onInteractionWithKeyboardInterupted() {}
    final protected void onMousePressedOutsideWhileInteractingWithKeyboard() {}
    protected int getHoverCursorIcon(float x, float y) {return Interactable.Cursor.ARROW;}
    protected void onUpdate() {}
    protected void onDraw(PGraphics pg) {
        pg.textSize(10);
        float textWidth = pg.textWidth(this.text) * 0.1;
        float textSize = (float)Math.min(this.getWidth() / textWidth, this.getHeight());
        pg.textSize(textSize);
        pg.textAlign(this.align, PConstants.CENTER);
        pg.fill(this.col,(this.col >> 24) & 0xFF);
        pg.rectMode(CORNERS);
        if (this.align == PConstants.LEFT) {
            pg.text(this.text, this.getLeft(), this.getCenterY() - textSize * 0.05);
        }
        else if (this.align == PConstants.RIGHT) {
            pg.text(this.text, this.getRight(), this.getCenterY() - textSize * 0.05);
        }
        else{
            pg.text(this.text, this.getCenterX(), this.getCenterY() - textSize * 0.05);
        }
    }
    abstract protected void action();
}
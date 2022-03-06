abstract static public class Slider extends Interactable{
    private int backgroundColor, foregroundColor, handleColor, textColor;
    private float min, max, value;
    private float handleSize;
    
    private float lastMouseX, lastMouseY;
    
    public Slider(float x1, float y1, float x2, float y2, String name, float value, float min, float max, float handleSize, int backgroundColor, int foregroundColor, int handleColor, int textColor) {
        super(x1, y1, x2, y2, name);
        this.setRange(min, max).setGlobalValue(value).setHandleSize(handleSize);
        this.setBackgroundColor(backgroundColor).setForegroundColor(foregroundColor);
        this.setHandleColor(handleColor).setTextColor(textColor);
    }
    
    final public int getBackgroundColor() {
        return this.backgroundColor;
    }
    final public Slider setBackgroundColor(int col) {
        this.backgroundColor = col;
        return this;
    }
    final public int getHandleColor() {
        return this.handleColor;
    }
    final public Slider setHandleColor(int col) {
        this.handleColor = col;
        return this;
    }
    final public int getTextColor() {
        return this.textColor;
    }
    final public Slider setTextColor(int col) {
        this.textColor = col;
        return this;
    }
    final public int getForegroundColor() {
        return this.backgroundColor;
    }
    final public Slider setForegroundColor(int col) {
        this.foregroundColor = col;
        return this;
    }
    final public float getHandleSize() {
        return this.handleSize;
    }
    final public Slider setHandleSize(float handleSize) {
        this.handleSize = (float)Math.min(0.5, Math.max(0, handleSize));
        return this;
    }
    
    final public float getMinimum() {
        return this.min;
    }
    final public float getMaximum() {
        return this.max;
    }
    final public Slider setMinimum(float min) {
        this.min = min > this.max ? this.max : min;
        return this;
    }
    final public Slider setMaximum(float max) {
        this.max = max > this.min ? this.min : max;
        return this;
    }
    final public Slider setRange(float min, float max) {
        if (min > max) {
            float temp = min;
            max = min;
            min = temp;
        }
        this.min = min;
        this.max = max;
        return this;
    }
    final public float getLocalValue() {
        return this.value;
    }
    final public float getGlobalValue() {
        return this.min + (this.max - this.min) * this.value;
    }
    final public Slider setLocalValue(float value) {
        value = (float)Math.min(1, Math.max(0, value));
        if (value == this.value) return this;
        this.value = value;
        this.onValueChanged();
        return this;
    }
    final public Slider setGlobalValue(float value) {
        if (this.max - this.min == 0) {
            this.value = 0;
            return this;
        }
        value = (float)Math.min(this.max, Math.max(this.min, value));
        value = (value - this.min) / (this.max - this.min);
        if (value == this.value) return this;
        this.value = value;
        this.onValueChanged();
        return this;
    }
    
    final public Rect getHandleLocalRect() {
        if (this.getWidth() > this.getHeight()) {
            float handleSize = this.handleSize * this.getWidth();
            float handleMin = handleSize * 0.5;
            float handleMax = this.getWidth() - handleSize * 0.5;
            float handleCenter = handleMin + (handleMax - handleMin) * this.value;
            float handleLeft = handleCenter - handleSize * 0.5;
            float handleRight = handleCenter + handleSize * 0.5;
            return new Rect(handleLeft, 0, handleRight, this.getHeight());
        }
        else{
            float handleSize = this.handleSize * this.getHeight();
            float handleMin = handleSize * 0.5;
            float handleMax = this.getHeight() - handleSize * 0.5;
            float handleCenter = handleMin + (handleMax - handleMin) * this.value;
            float handleTop = handleCenter - handleSize * 0.5;
            float handleBottom = handleCenter + handleSize * 0.5;
            return new Rect(0, handleTop, this.getWidth(), handleBottom);
        }   
    }
    final public Rect getHandleGlobalRect() {
        return this.getHandleLocalRect().translate(this.getLeft(), this.getTop());
    }
    final protected void onMousePressed(float x, float y) {
        if (this.getWidth() > this.getHeight()) {
            float handleSize = this.handleSize * this.getWidth();
            float handleMin = handleSize * 0.5;
            float handleMax = this.getWidth() - handleSize * 0.5;
            float handleCenter = handleMin + (handleMax - handleMin) * this.value;
            float handleLeft = handleCenter - handleSize * 0.5;
            float handleRight = handleCenter + handleSize * 0.5;
            if (x <handleLeft || x > handleRight) this.setLocalValue((x - handleMin) / (handleMax - handleMin));
            this.lastMouseX = (float)Math.min(handleMax, Math.max(handleMin, x));
            this.lastMouseY = y;
        }
        else{
            float handleSize = this.handleSize * this.getHeight();
            float handleMin = handleSize * 0.5;
            float handleMax = this.getHeight() - handleSize * 0.5;
            float handleCenter = handleMin + (handleMax - handleMin) * this.value;
            float handleTop = handleCenter - handleSize * 0.5;
            float handleBottom = handleCenter + handleSize * 0.5;
            if (x <handleTop || x > handleBottom) this.setLocalValue((y - handleMin) / (handleMax - handleMin));
            this.lastMouseX = x;
            this.lastMouseY = (float)Math.min(handleMax, Math.max(handleMin, y));
        }
    }
    final protected void onMouseDragged(float x, float y) {
        if (this.getWidth() > this.getHeight()) {
            float handleSize = this.handleSize * this.getWidth();
            float handleMin = handleSize * 0.5;
            float handleMax = this.getWidth() - handleSize * 0.5;
            float deltaMouse = x - this.lastMouseX;
            float deltaValue = deltaMouse / (handleMax - handleMin);
            this.setLocalValue(this.value + deltaValue);
            this.lastMouseX = (float)Math.min(handleMax, Math.max(handleMin, x));
            this.lastMouseY = y;
        }
        else{
            float handleSize = this.handleSize * this.getHeight();
            float handleMin = handleSize * 0.5;
            float handleMax = this.getHeight() - handleSize * 0.5;
            float deltaMouse = y - this.lastMouseY;
            float deltaValue = deltaMouse / (handleMax - handleMin);
            this.setLocalValue(this.value + deltaValue);
            this.lastMouseX = x;
            this.lastMouseY = (float)Math.min(handleMax, Math.max(handleMin, y));
        }
    }
    final protected void onMouseReleased() {}
    final protected void onMouseMoved(float x, float y) {}
    final protected void onPressedInterupted() {}
    final protected void onKeyPressed(char key, int keyCode) {}
    final protected void onKeyReleased(char key, int keyCode) {}
    final protected void onInteractionWithKeyboardStarted() {}
    final protected void onInteractionWithKeyboardEnded() {}
    final protected void onInteractionWithKeyboardInterupted() {}
    final protected void onMousePressedOutsideWhileInteractingWithKeyboard() {}
    final protected int getHoverCursorIcon(float x, float y) {
        return Interactable.Cursor.HAND;
    }
    protected void onUpdate() {}
    final protected void onDraw(PGraphics pg) {
        if (this.getWidth() < 1 || this.getHeight() < 1) return;
        
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
        
        pg.fill(this.backgroundColor,(this.backgroundColor >> 24) & 0xFF);
        pg.noStroke();
        pg.rect(left, top, right, bottom);
        
        pg.fill(this.handleColor,(this.handleColor >> 24) & 0xFF);
        pg.rect(handleLeft, handleTop, handleRight, handleBottom);
        
        String text = this.getDisplayString(this.getGlobalValue());
        text= text == null ? "" : text;
        pg.textSize(10);
        float textWidth = pg.textWidth(text) * 0.1;
        float textSize = (float)Math.min(handleRect.getWidth() / textWidth, handleRect.getHeight()) * 0.8;
        pg.textSize(textSize);
        pg.textAlign(PConstants.CENTER, PConstants.CENTER);
        pg.fill(this.textColor,(this.textColor >> 24) & 0xFF);
        pg.text(text, handleRect.getCenterX(), handleRect.getCenterY());
        
        pg.noFill();
        pg.stroke(this.foregroundColor,(this.foregroundColor >> 24) & 0xFF);
        pg.strokeWeight(1);
        pg.rect(left, top, right, bottom);
    }
    
    abstract protected void onValueChanged();
    abstract protected String getDisplayString(float value);
}
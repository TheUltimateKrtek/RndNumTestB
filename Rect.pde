static class Rect{
    float x1, y1, x2, y2;
    
    public Rect(float x1, float y1, float x2, float y2) {
        this.x1 = x1;
        this.y1 = y1;
        this.x2 = x2;
        this.y2 = y2;
    }
    
    public Rect translate(float x, float y) {
        this.x1 += x;
        this.y1 += y;
        this.x2 += x;
        this.y2 += y;
        return this;
    }
    
    final public Rect set(float x1, float y1, float x2, float y2) {
        this.x1 = x1;
        this.y1 = y1;
        this.x2 = x2;
        this.y2 = y2;
        return this;
    }
    final public float getLeft() {
        return(float)Math.min(this.x1, this.x2);
    }
    final public float getRight() {
        return(float)Math.max(this.x1, this.x2);
    }
    final public float getTop() {
        return(float)Math.min(this.y1, this.y2);
    }
    final public float getBottom() {
        return(float)Math.max(this.y1, this.y2);
    }
    final public float getCenterX() {
        return(this.x1 + this.x2) * 0.5;
    }
    final public float getCenterY() {
        return(this.y1 + this.y2) * 0.5;
    }
    final public float getWidth() {
        return(float)Math.abs(this.x1 - this.x2);
    }
    final public float getHeight() {
        return(float)Math.abs(this.y1 - this.y2);
    }
    
    final public boolean isPointInside(float x, float y) {
        float left = this.getLeft();
        float right = this.getRight();
        float top = this.getTop();
        float bottom = this.getBottom();
        return x >= left && x <= right && y >= top && y <= bottom;
    }
}
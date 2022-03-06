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
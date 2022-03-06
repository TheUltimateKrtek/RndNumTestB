static public class Layout{
    static public PApplet applet;
    final static public float buttonLayerHeight = 0.4;
    
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
    static public Button saveResolutionButton, loadFontButton;
    static public Button addLeft, addAbove, addRight, addBelow, removeRow, removeColumn;
    static public Button sortButton;
    static public Button versionCheck;
    
    static public void clear() {
        Interactable.clear();
    }
    static public void generateLayout() {
        Layout.generateLayout(Layout.applet);
    }
    static public void generateLayout(PApplet applet) {
        if (applet == null) return;
        Layout.generateLayout(applet.width, applet.height);
    }
    static public void generateLayout(int width, int height) {
        Interactable.clear();
        float buttonsTop = height * (1 - Layout.buttonLayerHeight);
        Layout.generateImageInteractables(width, height);
        Layout.generateInformationInteractables(width, height);
}
    
    static public void clearImageInteractables() {
        if (Layout.imageButtons != null) {
            for (int row = 0; row < Layout.imageButtons.length; row ++) {
                for (int column = 0; column < Layout.imageButtons[row].length; column ++) {
                    Layout.imageButtons[row][column].destroy();
                    Layout.imageButtons[row][column] = null;
                }
        }
            Layout.imageButtons = null;
        }
        if (Layout.imageButton != null) {
            Layout.imageButton.destroy();
            Layout.imageButton = null;
        }
    }
    static public void generateImageInteractables() {
        Layout.generateImageInteractables(Layout.applet);
    }
    static public void generateImageInteractables(PApplet applet) {
        if (applet == null) return;
        Layout.generateImageInteractables(applet.width, applet.height);
    }
    static public void generateImageInteractables(int width, int height) {
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
        Layout.imageButton = new Button(0, 0, width, buttonsTop, "image", "", 0x00000000, PConstants.CENTER) {
            protected void action() {
                Global.selectedRow = -1;
                Global.selectedColumn = -1;
                Layout.clear();
                Layout.generateLayout();
        }
        };
        Layout.imageButtons = new Button[rowBorders.length][columnBorders.length];
        for (int row = 0; row < rowBorders.length; row ++) {
            for (int column = 0; column < columnBorders.length; column ++) {
                float left = imageLeft + columnBorders[column][0];
                float right = imageLeft + columnBorders[column][1];
                float top = imageTop + rowBorders[row][0];
                float bottom = imageTop + rowBorders[row][1];
                Layout.imageButtons[row][column] = new GeneratorButton(left, top, right, bottom, row, column);
        }
        }
}
    
    static public void clearInformationInteractables() {
        
    }
    static public void generateInformationInteractables() {
        Layout.generateInformationInteractables(Layout.applet);
    }
    static public void generateInformationInteractables(PApplet applet) {
        if (applet == null) return;
        Layout.generateInformationInteractables(applet.width, applet.height);
    }
    static public void generateInformationInteractables(int width, int height) {
        Layout.clearInformationInteractables();
        float buttonsTop = height * (1 - Layout.buttonLayerHeight);
        float buttonsHeight = height * Layout.buttonLayerHeight;
        
        float borderSize = buttonsHeight * 0.1;
        
        float[] xs = new float[13];
        for (int i = 0; i < xs.length; i ++) {
            xs[i] = borderSize + (width - borderSize * 2) * i / (xs.length - 1);
        }
        float[] ys = new float[13];
        for (int i = 0; i < ys.length; i ++) {
            ys[i] = buttonsTop + borderSize + (buttonsHeight - borderSize * 2) * i / (ys.length - 1);
        }
        
        if (Global.selectedRow >= 0 && Global.selectedColumn >= 0) {
            Layout.rowIndexText = new TextField(xs[0], ys[0], xs[3], ys[1], "rowdisplay", "Row: " + Global.selectedRow, false, 0xFFFFFFFF, 0xFFFFFFFF) {
                protected void onUpdate() {
                    this.setDefaultText("Řádek: " + Global.selectedRow);
                }
                protected boolean isValidCharacter(char character) {return true;}
                protected void onTextChanged() {}
            };
            Layout.columnIndexText = new TextField(xs[0], ys[1], xs[3], ys[2], "columndisplay", "Column: " + Global.selectedColumn, false, 0xFFFFFFFF, 0xFFFFFFFF) {
                protected void onUpdate() {
                    this.setDefaultText("Sloupec: " + Global.selectedColumn);
                }
                protected boolean isValidCharacter(char character) {return true;}
                protected void onTextChanged() {}
            };
            Layout.maxDigitsText = new TextField(xs[0], ys[3], xs[4], ys[4], "maxdigitstext", "Max digits: " + Global.generator.getColumnSize(Global.selectedColumn), false, 0xFFFFFFFF, 0xFFFFFFFF) {
                protected void onUpdate() {
                    this.setDefaultText("Maximální počet cifer: " + Global.generator.getColumnSize(Global.selectedColumn));
                }
                protected boolean isValidCharacter(char character) {return true;}
                protected void onTextChanged() {}
            };
            Layout.maxDigitsSlider = new Slider(xs[4], ys[3], xs[8], ys[4], "maxdigitsslider", Global.generator.getColumnSize(Global.selectedColumn), 1, 32, 0.25, 0x00000000, 0xFFFFFFFF, 0x7FFFFFFF, 0xFFFFFFFF) {
                protected String getDisplayString(float value) {
                   return(int)Math.round(value) + "";
                }
                protected void onValueChanged() {
                    int value = (int)Math.round(this.getGlobalValue());
                    if (value == Global.generator.getColumnSize(Global.selectedColumn)) return;
                    Global.generator.setColumnSize(Global.selectedColumn, value, true);
                    Layout.generateImageInteractables();
                }
            };
            Layout.alignmentText = new TextField(xs[0], ys[4], xs[4], ys[5], "aligntext", "Aligned: " + (Global.generator.isColumnAlignedLeft(Global.selectedColumn) ? "Left" : "Right"), false, 0xFFFFFFFF, 0xFFFFFFFF) {
                protected void onUpdate() {
                    this.setDefaultText("Zarovnání: " + (Global.generator.isColumnAlignedLeft(Global.selectedColumn) ? "Doleva" : "Doprava"));
                }
                protected boolean isValidCharacter(char character) {return true;}
                protected void onTextChanged() {}
            };
            Layout.alignLeftButton = new Button(xs[4], ys[4], xs[6], ys[5], "alignleftbutton", "| <-", 0xFFFFFFFF, PConstants.CENTER) {
                protected void action() {
                    Global.generator.setColumnAlign(Global.selectedColumn, true);
                }
                protected void onUpdate() {
                    if (Global.generator.isColumnAlignedLeft(Global.selectedColumn)) this.setColor(0xFFFFFFFF);
                    else this.setColor(0xFF7F7F7F);
                }
                protected void onDraw(PGraphics pg) {
                    pg.pushMatrix();
                    pg.translate(0, this.getHeight() * 0.05);
                    super.onDraw(pg);
                    pg.popMatrix();
                }
            };
            Layout.alignRightButton = new Button(xs[6], ys[4], xs[8], ys[5], "alignrightbutton", "-> |", 0xFFFFFFFF, PConstants.CENTER) {
                protected void action() {
                    Global.generator.setColumnAlign(Global.selectedColumn, false);
                }
                protected void onUpdate() {
                    if (Global.generator.isColumnAlignedRight(Global.selectedColumn)) this.setColor(0xFFFFFFFF);
                    else this.setColor(0xFF7F7F7F);
                }
                protected void onDraw(PGraphics pg) {
                    pg.pushMatrix();
                    pg.translate(0, this.getHeight() * 0.05);
                    super.onDraw(pg);
                    pg.popMatrix();
                }
            };
            Layout.colorText = new TextField(xs[0], ys[5], xs[4], ys[6], "aligntext", "Aligned: " + (Global.generator.isColumnAlignedLeft(Global.selectedColumn) ? "Left" : "Right"), false, 0xFFFFFFFF, 0xFFFFFFFF) {
                protected void onUpdate() {
                    this.setDefaultText("Barva: ");
                }
                protected boolean isValidCharacter(char character) {return true;}
                protected void onTextChanged() {}
            };
            Layout.colorButton = new ColorButton(xs[4], ys[5], xs[8], ys[6], "colorselector");
            Layout.numberText = new TextField(xs[0], ys[7], xs[4], ys[8], "numbertext", "Číslo", false, 0xFFFFFFFF, 0xFFFFFFFF) {
                protected void onTextChanged() {}
                protected boolean isValidCharacter(char key) {return true;}
            };
            Layout.numberField = new TextField(xs[4], ys[7], xs[8], ys[8], "numberinput", "Číslo", true, 0xFFFFFFFF, 0xFF7F7F7F) {
                protected void onTextChanged() {
                    if (Global.selectedRow < 0 || Global.selectedColumn < 0) return;
                    Global.generator.setString(Global.selectedRow, Global.selectedColumn, this.getCurrentText());
                    
                }
                protected void onUpdate() {
                    if (Global.selectedRow < 0 || Global.selectedColumn < 0) return;
                    this.setTextColor(Global.generator.getRowColor(Global.selectedRow));
                    this.setCurrentText(Global.generator.getString(Global.selectedRow, Global.selectedColumn));
                }
                protected boolean isValidCharacter(char key) {
                   return Character.isDigit(key);
                }
            };
            Layout.addLeft = new Button(xs[0], ys[9], xs[3], ys[10], "addleftbutton", "Přidat sloupec vlevo", 0xFFFFFFFF, PConstants.RIGHT) {
                protected void action() {
                    Global.generator.addRandomColumn(Global.selectedColumn);
                    Layout.generateLayout();
                }
            };
            Layout.addRight = new Button(xs[3], ys[9], xs[6], ys[10], "addleftbutton", "Přidat sloupec vpravo", 0xFFFFFFFF, PConstants.RIGHT) {
                protected void action() {
                    Global.generator.addRandomColumn(Global.selectedColumn + 1);
                    Global.selectedColumn ++;
                    Layout.generateLayout();
                }
            };
            Layout.addAbove = new Button(xs[6], ys[9], xs[9], ys[10], "addleftbutton", "Přidat řádek nad", 0xFFFFFFFF, PConstants.RIGHT) {
                protected void action() {
                    Global.generator.addRandomRow(Global.selectedRow);
                    Layout.generateLayout();
                }
            };
            Layout.addBelow = new Button(xs[9], ys[9], xs[12], ys[10], "addleftbutton", "Přidat řádek pod", 0xFFFFFFFF, PConstants.RIGHT) {
                protected void action() {
                    Global.generator.addRandomColumn(Global.selectedRow + 1);
                    Global.selectedRow ++;
                    Layout.generateLayout();
                }
            };
            Layout.removeRow = new Button(xs[0], ys[10], xs[3], ys[11], "removerowbutton", "Odebrat řádek", 0xFFFFFFFF, PConstants.RIGHT) {
                protected void action() {
                    Global.generator.removeRow(Global.selectedRow);
                    Global.selectedRow --;
                    Layout.generateLayout();
                }
            };
            Layout.removeColumn = new Button(xs[3], ys[10], xs[6], ys[11], "removerowbutton", "Odebrat sloupec", 0xFFFFFFFF, PConstants.RIGHT) {
                protected void action() {
                    Global.generator.removeColumn(Global.selectedColumn);
                    Global.selectedColumn --;
                    Layout.generateLayout();
                }
            };
        }
        Layout.generateText = new Button(xs[9], ys[0], xs[12], ys[1], "generatebutton", "Generovat náhodný", 0xFFFFFFFF, PConstants.RIGHT) {
            protected void action() {
                Global.recreateGenerator();
                Layout.generateLayout();
            }
        };
        Layout.saveText = new Button(xs[9], ys[2], xs[12], ys[3], "savebutton", "Uložit jako...", 0xFFFFFFFF, PConstants.RIGHT) {
            protected void onUpdate() {
                if (System.currentTimeMillis() - Global.lastSaved < 3000) {
                    float perc= (System.currentTimeMillis() - Global.lastSaved) / 3000.0;
                    if (Global.saveState == 1) {
                        this.setColor(Layout.applet.lerpColor(0xFFFF1F1F, 0xFFFFFFFF, perc * perc));
                        this.setText("Chyba ukládání!");
                    }
                    else if (Global.saveState == 2) {
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
            protected void action() {
                Global.save();
            }
        };
        Layout.saveResolutionButton = new Button(xs[9], ys[3], xs[12], ys[4] - (ys[1] - ys[0]) * 0.05, "resolutiontextbutton", "Resolution", 0xFFFFFFFF, PConstants.RIGHT) {
            protected void onUpdate() {
                int width = (int)Global.generator.getGraphicsWidth(Global.outputScale);
                int height = (int)Global.generator.getGraphicsHeight(Global.outputScale);
                this.setText(width + "x" + height);
            }
            protected void action() {}
        };
        Layout.saveSizeSlider = new Slider(xs[9], ys[4], xs[12], ys[5], "savesizeslider", Global.outputScale, 10, 200, 0.2, 0x00000000, 0xFFFFFFFF, 0x7FFFFFFF, 0xFFFFFFFF) {
            protected void onValueChanged() {
                Global.setOutputScale((int)Math.round(this.getGlobalValue()));
            }
            protected String getDisplayString(float value) {
                return "";
            }
        };
        Layout.loadFontButton = new FontButton(xs[9], ys[6], xs[12], ys[7], "loadfongbutton", "Zvolit font", 0xFFFFFFFF, PConstants.RIGHT, Layout.applet) {
            protected void onUpdate() {
                if (Global.font == null) this.setText("Zvolit font...");
               else this.setText("Font: " + Global.font.getName());
            }
            protected void action() {
                Global.loadFont();
            }
        };
        Layout.sortButton = new Button(xs[9], ys[8], xs[12], ys[9], "sortbutton", "Seřadit podle barvy", 0xFFFFFFFF, PConstants.RIGHT) {
            protected void action() {
                Global.generator.sortByColor();
                Global.selectedRow = -1;
                Layout.generateLayout();
            }
        };
        Layout.versionCheck = new Button(xs[0], ys[11], xs[10], ys[12], "versioncheckbutton", "Seřadit podle barvy", 0xFFFFFFFF, PConstants.LEFT) {
            protected void update(){
                int code = Application.getUpdateMessageCode();
                if(!Application.showUpdateMessage){
                    this.setText("").setColor(0x00000000);
                }
                else if(code == 0){
                    this.setText("").setColor(0x00000000);
                }
                else if(code == 1){
                    this.setText("Kontrola verze... (Kliknutím sem zavřete toto okno)").setColor(0xFFBFBF1F);
                }
                else if(code == 2){
                    this.setText("Kontrola verze se nezdařila... (Kliknutím sem zavřete toto okno)").setColor(0xFFFF1F1F);
                }
                else if(code == 3){
                    this.setText("Program je aktuální. (Kliknutím sem zavřete toto okno)").setColor(0xFFFFFFFF);
                }
                else{
                    this.setText("Nová verze programu byla nalezena. Kliknutím sem jí stáhnete.").setColor(0xFFBFBF1F);
                }
            }
            protected void action() {
                int code = Application.getUpdateMessageCode();
                if(!Application.showUpdateMessage){

                }
                if(code == 0){
                    Application.showUpdateMessage = false;
                }
                else if(code == 1){
                    Application.showUpdateMessage = false;
                }
                else if(code == 2){
                    Application.showUpdateMessage = false;
                }
                else if(code == 3){
                    Application.showUpdateMessage = false;
                }
                else{
                    try{
                        java.awt.Desktop.getDesktop().browse(new java.net.URI("https://github.com/TheUltimateKrtek/RndNumTestB/releases"));
                    }
                    catch(Exception e){}
                }
            }
        };
    }
    
    final static public class GeneratorButton extends Button{
        final public int row, column;
        
        public GeneratorButton(float x1, float y1, float x2, float y2, int row, int column) {
            super(x1, y1, x2, y2, "generatorbuttonr" + row + "c" + column, "", 0x00000000, PConstants.CENTER);
            this.row = row;
            this.column = column;
        }
        
        protected void onDraw(PGraphics pg) {
            super.onDraw(pg);
            if (this.row == Global.selectedRow && this.column == Global.selectedColumn) {
                pg.noFill();
                pg.strokeWeight(2);
                pg.stroke(255);
                pg.rectMode(CORNERS);
                pg.rect(this.getLeft(), this.getTop(), this.getRight(), this.getBottom());
        }
        }
        
        protected void action() {
            Global.selectedRow = this.row;
            Global.selectedColumn = this.column;
            Layout.clear();
            Layout.generateLayout();
        }
    }
    static abstract public class FontButton extends Button{
        private PApplet applet;
        
        public FontButton(float x1, float y1, float x2, float y2, String name, String text, int col, int align, PApplet applet) {
            super(x1, y1, x2, y2, name, text, col, align);
            this.applet = applet;
        }
        
        protected void onDraw(PGraphics pg) {
            if(this.applet == null){
                super.onDraw(pg);
                return;
            }
            if(this.getWidth() < 1 || this.getHeight() < 1) return;

            PGraphics graphics = this.applet.createGraphics(pg.width, pg.height);
            graphics.beginDraw();

            if(Global.font != null) graphics.textFont(Global.font);

            graphics.textSize(10);
            float textWidth = graphics.textWidth(this.getText()) * 0.1;
            float textSize = (float)Math.min(this.getWidth() / textWidth, this.getHeight());
            graphics.textSize(textSize);
            graphics.textAlign(this.getAlign(), PConstants.CENTER);
            graphics.fill(this.getColor(), (this.getColor() >> 24) & 0xFF);
            graphics.rectMode(CORNERS);
            if (this.getAlign() == PConstants.LEFT) {
                graphics.text(this.getText(), this.getLeft(), this.getCenterY() - textSize * 0.05);
            }
            else if (this.getAlign() == PConstants.RIGHT) {
                graphics.text(this.getText(), this.getRight(), this.getCenterY() - textSize * 0.05);
            }
            else{
                graphics.text(this.getText(), this.getCenterX(), this.getCenterY() - textSize * 0.05);
            }


            graphics.endDraw();
            pg.imageMode(PConstants.CORNERS);
            pg.image(graphics, 0, 0, pg.width, pg.height);
        }
    }
    final static public class ColorButton extends Interactable{
        static final public float colorPickedHeight = 0.2;
        public ColorButton(float x1, float y1, float x2, float y2, String name) {
            super(x1, y1, x2, y2, name);
        }
        
        final protected void onMousePressed(float x, float y) {
            if (Global.selectedRow < 0 || Global.selectedColumn < 0) return;
            if (x <this.getHeight() * ColorButton.colorPickedHeight) return;
            int[] colors = Generator.getAllColors();
            int index = (int)Math.min(colors.length - 1, x * colors.length / this.getWidth());
            Global.generator.setRowColorIndex(Global.selectedRow, index);
        }
        final protected void onMouseDragged(float x, float y) {
            if (Global.selectedRow < 0 || Global.selectedColumn < 0) return;
            if (x <this.getHeight() * ColorButton.colorPickedHeight) return;
            int[] colors = Generator.getAllColors();
            int index = (int)Math.min(colors.length - 1, Math.max(0, x * colors.length / this.getWidth()));
            Global.generator.setRowColorIndex(Global.selectedRow, index);
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
        final protected int getHoverCursorIcon(float x, float y) {return Interactable.Cursor.HAND;}
        final protected void onUpdate() {}
        final protected void onDraw(PGraphics pg) {
            if (Global.selectedRow < 0 || Global.selectedColumn < 0) return;
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
            
            for (int i = 0; i < colors.length; i ++) {
                pg.fill(colors[i]);
                pg.rect(left + width * i / colors.length, top + height * ColorButton.colorPickedHeight, left + width * (i + 1) / colors.length, bottom);
            }
        }
    }
}
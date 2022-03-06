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
        #54f1ff,
        #C2C200,
        #00FF00,
        #FF00FF,
        #FFFFFF,
        #FF1F1F
    };
    private static final float borderHeight = 0.2;
    private static final float borderWidth = 0.5;
    
    public Generator(PApplet applet, PFont font, long seed, int[] cols, int[] sizes, boolean[] lefts) {
        if (applet == null || sizes == null || cols == null || lefts == null) throw new NullPointerException("Something is null");
        if (sizes.length == 0) throw new IllegalArgumentException("The size array is zero values long.");
        for (int i = 0; i < sizes.length; i ++) {
            if (sizes[i] < 1) throw new IllegalArgumentException("One of the sizes is out of range. Index: " + i + ", Value: " + cols[i]);
        }
        if (cols.length == 0) throw new IllegalArgumentException("The col array is zero values long.");
        for (int i = 0; i < cols.length; i ++) {
            if (cols[i] < 0 || cols[i] > 6) throw new IllegalArgumentException("One of the sizes is out of range. Index: " + i + ", Value: " + cols[i]);
        }
        if (lefts.length != sizes.length) throw new IllegalArgumentException("The lefts array is not the same length as the size array.");
        
        this.applet = applet;
        this.font = font;
        this.characterWidth = this.getCharacterWidth();
        this.seed = seed;
        this.random = new Random(this.seed);
        
        this.sizes = sizes;
        this.cols = cols;
        this.lefts = lefts;
        
        this.strings = new String[this.cols.length][this.sizes.length];
        for (int row = 0; row < this.strings.length; row ++) {
            for (int column = 0; column < this.strings[row].length; column ++) {
                strings[row][column] = this.generateRandomString(this.sizes[column]);
        }
        }
    }
    
    public Generator setFont(PFont font) {
        this.font = font;
        return this;
    }
    
    static public int[] getAllColors() {
        int[] rl = new int[Generator.possibleColors.length];
        for (int i = 0; i < rl.length; i ++) rl[i] = Generator.possibleColors[i];
        return rl;
    }
    
    static public Generator createRandomGenerator(PApplet applet, PFont font, long seed, int maxRowCount, int maxCharacterCount) {
        if (applet == null) throw new NullPointerException("Applet is null.");
        if (maxRowCount < 1 || maxCharacterCount < 1) throw new IllegalArgumentException();
        
        Random random = new Random(seed);
        
        IntList columnSizes = new IntList();
        int totalSize = 0;
        while(totalSize < maxCharacterCount) {
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
        for (int i = 0; i < cols.length; i ++) cols[i] = random.nextInt(Generator.possibleColors.length);
        for (int i = 0; i < cols.length - 1; i ++) {
            for (int j = 0; j < cols.length - i - 1; j ++) {
                if (cols[j] > cols[j + 1]) {
                    int temp =cols[j];
                    cols[j] = cols[j + 1];
                   cols[j + 1] = temp;
                }
        }
        }
        boolean[] lefts = new boolean[sizes.length];
        for (int i = 0; i < lefts.length; i ++) lefts[i] = random.nextBoolean();
        
        return new Generator(applet, font, random.nextLong(), cols, sizes, lefts);
    }
    
    public int getColumnCount() {
        return this.sizes.length;
    }
    public int getRowCount() {
        return this.cols.length;
    }
    public int getRowCharacterCount() {
        int sum = 0;
        for (int i = 0; i < this.sizes.length; i ++) sum += this.sizes[i];
        return sum;
    }
    
    public Generator addRandomRow(int index) {
        return this.addRow(index, this.random.nextInt(Generator.possibleColors.length));
    }
    public Generator addRow(int col) {
        return this.addRow(Integer.MAX_VALUE, col);
    }
    public Generator addRow(int index, int col) {
        if (col < 0 || col >= Generator.possibleColors.length) return this;
        index = Math.min(this.getRowCount(), Math.max(0, index));
        
        int[] cols = new int[this.cols.length + 1];
        String[][] strings = new String[this.strings.length + 1][this.strings[0].length];
        
        for (int row = 0; row < index; row ++) {
            cols[row] = this.cols[row];
            for (int column = 0; column < this.getColumnCount(); column ++) {
                strings[row][column] = this.strings[row][column];
        }
        }
        
        cols[index] = col;
        for (int column = 0; column < this.getColumnCount(); column ++) {
            strings[index][column] = this.generateRandomString(this.sizes[column]);
        }
        
        for (int row = index + 1; row < cols.length; row ++) {
            cols[row] = this.cols[row - 1];
            for (int column = 0; column < this.getColumnCount(); column ++) {
                strings[row][column] = this.strings[row - 1][column];
        }
        }
        
        this.cols = cols;
        this.strings = strings;
        
        return this;
    }
    public Generator removeRow(int index) {
        if (this.getRowCount() <= 1 || index < 0 || index >= this.getRowCount()) return this;
        
        int[] cols = new int[this.cols.length - 1];
        String[][] strings = new String[this.strings.length - 1][this.strings[0].length];
        
        for (int row = 0; row < index; row ++) {
            cols[row] = this.cols[row];
            for (int column = 0; column < this.getColumnCount(); column ++) {
                strings[row][column] = this.strings[row][column];
        }
        }
        
        for (int row = index; row < cols.length; row ++) {
            cols[row] = this.cols[row + 1];
            for (int column = 0; column < this.getColumnCount(); column ++) {
                strings[row][column] = this.strings[row + 1][column];
        }
        }
        
        this.cols = cols;
        this.strings = strings;
        
        return this;
    }
    public int getRowColorIndex(int index) {
        if (index < 0 || index >= this.getRowCount()) return - 1;
        return this.cols[index];
    }
    public int getRowColor(int index) {
        if (index < 0 || index >= this.getRowCount()) return - 1;
        return Generator.possibleColors[this.cols[index]];
    }
    public Generator setRowColorIndex(int index, int col) {
        if (index < 0 || index >= this.getRowCount()) return this;
        this.cols[index] = col;
        return this;
    }
    
    public Generator addRandomColumn(int index) {
        return this.addColumn(index, this.random.nextInt(32) + 1, this.random.nextBoolean());
    }
    public Generator addColumn(int size, boolean isLeftAligned) {
        return this.addColumn(Integer.MAX_VALUE, size, isLeftAligned);
    }
    public Generator addColumn(int index, int size, boolean isLeftAligned) {
        index = Math.min(this.getColumnCount(), Math.max(0, index));
        
        int[] sizes = new int[this.sizes.length + 1];
        boolean[] lefts = new boolean[this.lefts.length + 1];
        String[][] strings = new String[this.strings.length][this.strings[0].length + 1];
        
        for (int column = 0; column < index; column ++) {
            sizes[column] = this.sizes[column];
            lefts[column] = this.lefts[column];
            for (int row = 0; row < this.getRowCount(); row ++) {
                strings[row][column] = this.strings[row][column];
        }
        }
        
        sizes[index] = size;
        lefts[index] = isLeftAligned;
        for (int row = 0; row < this.getRowCount(); row ++) {
            strings[row][index] = this.generateRandomString(size);
        }
        
        for (int column = index + 1; column < sizes.length; column ++) {
            sizes[column] = this.sizes[column - 1];
            lefts[column] = this.lefts[column - 1];
            for (int row = 0; row < this.getRowCount(); row ++) {
                strings[row][column] = this.strings[row][column - 1];
        }
        }
        
        this.sizes = sizes;
        this.lefts = lefts;
        this.strings = strings;
        
        return this;
    }
    public Generator removeColumn(int index) {
        if (index < 0 || index >= this.getColumnCount() || this.getColumnCount() == 1) return this;
        
        int[] sizes = new int[this.sizes.length - 1];
        boolean[] lefts = new boolean[this.lefts.length - 1];
        String[][] strings = new String[this.strings.length][this.strings[0].length - 1];
        
        for (int column = 0; column < index; column ++) {
            sizes[column] = this.sizes[column];
            lefts[column] = this.lefts[column];
            for (int row = 0; row < this.getRowCount(); row ++) {
                strings[row][column] = this.strings[row][column];
        }
        }
        
        for (int column = index; column < sizes.length; column ++) {
            sizes[column] = this.sizes[column + 1];
            lefts[column] = this.lefts[column + 1];
            for (int row = 0; row < this.getRowCount(); row ++) {
                strings[row][column] = this.strings[row][column + 1];
        }
        }
        
        this.sizes = sizes;
        this.lefts = lefts;
        this.strings = strings;
        
        return this;
    }
    public int getColumnSize(int index) {
        if (index < 0 || index >= this.getColumnCount()) return - 1;
        return this.sizes[index];
    }
    public Generator setColumnSize(int index, int size) {
        if (index < 0 || index >= this.getColumnCount()) return this;
        this.sizes[index] = size;
        for (int row = 0; row < this.getRowCount(); row ++) {
            strings[row][index] = this.adaptString(strings[row][index], size);
        }
        return this;
    }
    public Generator setColumnSize(int index, int size, boolean generateNew) {
        if (index < 0 || index >= this.getColumnCount()) return this;
        this.sizes[index] = size;
        for (int row = 0; row < this.getRowCount(); row ++) {
            strings[row][index] = this.adaptString(strings[row][index], size, generateNew);
        }
        return this;
    }
    public boolean isColumnAlignedLeft(int index) {
        if (index < 0 || index >= this.getColumnCount()) return false;
        return this.lefts[index];
    }
    public boolean isColumnAlignedRight(int index) {
        if (index < 0 || index >= this.getColumnCount()) return false;
        return !this.lefts[index];
    }
    public Generator setColumnAlign(int index, boolean left) {
        if (index < 0 || index >= this.getColumnCount()) return this;
        this.lefts[index] = left;
        return this;
    }
    
    public String getString(int row, int column) {
        if (row < 0 || row >= this.getRowCount() || column < 0 || column >= this.getColumnCount()) return null;
        return this.strings[row][column];
    }
    public Generator setString(int row, int column, String string) {
        if (row < 0 || row >= this.getRowCount() || column < 0 || column >= this.getColumnCount()) return null;
        if (string == null) return this;
        if (string.length() == 0) return this;
        char[] chars = string.toCharArray();
        for (int i = 0; i < chars.length; i ++) {
            if (!Character.isDigit(chars[i])) return this;
        }
        this.strings[row][column] = adaptString(string, this.sizes[column]);
        return this;
    }
    
    public float getRowTop(int row, float scale) {
        if (row < 0 || row >= this.getRowCount() || scale <= 0) return Float.NaN;
        return(Generator.borderHeight * (row + 2) + row) * scale;
    }
    public float getRowBottom(int row, float scale) {
        if (row < 0 || row >= this.getRowCount() || scale <= 0) return Float.NaN;
        return(Generator.borderHeight * (row + 2) + row + 1) * scale;
    }
    public float getColumnLeft(int column, float scale) {
        if (column < 0 || column >= this.getColumnCount() || scale <= 0) return Float.NaN;
        float sum = Generator.borderWidth * 2;
        for (int i = 0; i < column; i ++) sum += this.sizes[i] * this.characterWidth + Generator.borderWidth;
        return sum * scale;
    }
    public float getColumnRight(int column, float scale) {
        if (column < 0 || column >= this.getColumnCount() || scale <= 0) return Float.NaN;
        float sum = Generator.borderWidth * 2;
        for (int i = 0; i < column; i ++) sum += this.sizes[i] * this.characterWidth + Generator.borderWidth;
        sum += this.sizes[column] * this.characterWidth;
        return sum * scale;
    }
    public float[] getStringBorders(int row, int column, float scale) {
        if (row < 0 || row >= this.getRowCount() || column < 0 || column >= this.getColumnCount() || scale <= 0) return new float[]{Float.NaN, Float.NaN, Float.NaN, Float.NaN};
        float top = Generator.borderHeight * (row + 2) + row;
        float bottom = top + 1;
        float left = Generator.borderWidth * 2;
        for (int i = 0; i < column; i ++) top += this.sizes[i] * this.characterWidth + Generator.borderWidth;
        float right = this.sizes[column] * this.characterWidth;
        return new float[]{left * scale, top * scale, right * scale, bottom * scale};
    }
    public float[][] getAllRowBorders(float scale) {
        float[][] rl = new float[this.getRowCount()][2];
        for (int row = 0; row < rl.length; row ++) {
            float top = Generator.borderHeight * (row + 2) + row;
            float bottom = top + 1;
            rl[row] = new float[]{top * scale, bottom * scale};
        }
        
        return rl;
    }
    public float[][] getAllColumnBorders(float scale) {
        float[][] rl = new float[this.getColumnCount()][2];
        rl[0][0] = Generator.borderWidth * 2;
        rl[0][1] = rl[0][0] + this.sizes[0] * this.characterWidth;
        for (int column = 1; column < rl.length; column ++) {
            rl[column][0] = rl[column - 1][1] + Generator.borderWidth;
            rl[column][1] = rl[column][0] + this.sizes[column] * this.characterWidth;
        }
        for (int i = 0; i < rl.length; i ++) {
            rl[i][0] *= scale;
            rl[i][1] *= scale;
        }
        return rl;
    }
    
    public float getGraphicsWidth(float scale) {
        float sum = 0;
        for (int column = 0; column < this.getColumnCount(); column ++) {
            sum +=this.sizes[column] * this.characterWidth;
        }
        //sum += this.getRowCharacterCount() * this.characterWidth;
        sum += Generator.borderWidth * (3 + this.getColumnCount());
        return sum * scale;
    }
    public float getGraphicsHeight(float scale) {
        return(Generator.borderHeight * (3 + this.getRowCount()) + this.getRowCount()) * scale;
    }
    public float getAppropriateScale(float w, float h) {
        if (w< 1 || h < 1) return Float.NaN;
        return(float)Math.min(w / this.getGraphicsWidth(1), h / this.getGraphicsHeight(1));
    }
    
    public PGraphics getGraphics(int scale) {
        float[][] rowBorders = this.getAllRowBorders(scale);
        float[][] columnBorders = this.getAllColumnBorders(scale);
        
        float width = columnBorders[columnBorders.length - 1][1] + Generator.borderWidth * scale * 2;
        float height = (rowBorders[rowBorders.length - 1][1] + Generator.borderHeight * scale * 2);
        
        PGraphics pg = this.applet.createGraphics((int)width,(int)height);
        pg.beginDraw();
        pg.background(0);
        if (this.font != null) pg.textFont(this.font);
        pg.textSize(scale);
        for (int row = 0; row < rowBorders.length; row ++) {
            for (int column = 0; column < columnBorders.length; column ++) {
                pg.fill(Generator.possibleColors[this.cols[row]], 255);
                
                float left = columnBorders[column][0];
                float right = columnBorders[column][1];
                float top = rowBorders[row][0];
                float bottom = rowBorders[row][1];
                
                //TODO: Character by character drawing
                if (this.lefts[column]) {
                    pg.textAlign(LEFT, CENTER);
                    pg.text(this.strings[row][column], left,(top + bottom) * 0.5);
                }
            else{
                    pg.textAlign(RIGHT, CENTER);
                    pg.text(this.strings[row][column], right,(top + bottom) * 0.5);
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
    
    private float getCharacterWidth() {
        PGraphics pg = this.applet.createGraphics(1, 1);
        pg.beginDraw();
        if (this.font != null) pg.textFont(this.font);
        pg.textSize(100);
        float textWidth = pg.textWidth("0") / 100;
        pg.endDraw();
        return textWidth;
    }
    
    private String generateRandomString(int size) {
        int digits = this.random.nextInt(size) + 1;
        if (size == 1) return this.random.nextInt(10) + "";
        String rs = "";
        rs += this.random.nextInt(9) + 1;
        for (int i = 1; i < digits; i ++) rs += this.random.nextInt(10);
        return rs;
    }
    private String adaptString(String s, int size) {
        if (s== null) return(this.random.nextInt(9) + 1) + "";
        if (s.length() >= size) s = s.substring(s.length() - size, s.length());
        if (s.startsWith("0") && s.length() > 1) {
            int rnd = this.random.nextInt(9) + 1;
            s = rnd + s.substring(1, s.length());
        }
        return s;
    }
    private String adaptString(String s, int size, boolean generateNew) {
        if (s== null) return(this.random.nextInt(9) + 1) + "";
        if (s.length() >= size) s = s.substring(s.length() - size, s.length());
        else if (generateNew) {
            int[] rnds = new int[4];
            for (int i = 0; i < rnds.length; i ++) rnds[i] = this.random.nextInt(size - s.length());
            int rnd = this.min(rnds) + s.length();
            String string = this.generateRandomString(rnd);
            if (string.length() > s.length()) {
                s = string.substring(string.length() - s.length()) + s;
                if (s.length() > size) s = s.substring(0, size);
            }
        }
        if (s.startsWith("0") && s.length() > 1) {
            int rnd = this.random.nextInt(9) + 1;
            s = rnd + s.substring(1, s.length());
        }
        return s;
    }
    private int min(int...nums) {
        if (nums.length == 0) return Integer.MIN_VALUE;
        int min = nums[0];
        for (int i : nums) min = Math.min(min, i);
        return min;
    }
    
    public Generator sortByColor() {
        int[] indexes = new int[this.cols.length];
        for (int i = 0; i < indexes.length; i ++) indexes[i] = i;
        
        for (int i = 0; i < indexes.length - 1; i ++) {
            for (int j = 0; j < indexes.length - i - 1; j ++) {
                if (this.cols[indexes[j]] > this.cols[indexes[j + 1]]) {
                    int temp =indexes[j];
                    indexes[j]= indexes[j + 1];
                    indexes[j + 1] = temp;
                }
        }
        }
        
        String[][] strings = new String[this.strings.length][this.strings[0].length];
        int[] cols = new int[this.cols.length];
        for (int row = 0; row < indexes.length; row ++) {
            for (int column = 0; column < strings[0].length; column ++) {
                strings[row][column] = this.strings[indexes[row]][column];
        }
            cols[row] = this.cols[indexes[row]];
        }
        this.strings = strings;
        this.cols = cols;
        return this;
    }
}
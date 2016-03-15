module gui.picker.picker;

import gui;
import gui.picker;

class Picker : Frame {
private:
    Ls _ls;
    Tiler _tiler;
    Scrollbar _scrollbar;

    MutFilename _basedir;

public:
    // Create both arguments separately, then give them to this class.
    static typeof(this) newPicker(T)(Geom g, Ls ls)
        if (is (T : Tiler))
    {
        assert (g.xl >= 20);
        assert (ls);
        return new typeof(this)(g, ls, new T(new Geom(0, 0, g.xl - 20, g.yl)));
    }

    @property Filename basedir() const { return _basedir; }
    @property Filename basedir(Filename fn)
    {
        assert (fn);
        assert (_ls);
        _basedir = fn;
        if (! _ls.currentDir || ! _ls.currentDir.isChildOf(_basedir))
            currentDir = _basedir;
        return basedir;
    }

    @property Filename currentDir() const {
        assert (_ls);
        return _ls.currentDir;
    }

    @property Filename currentDir(Filename fn)
    {
        assert (_ls);
        if (! fn) {
            if (basedir)
                currentDir = basedir;
            return currentDir;
        }
        if (currentDir == fn)
            return currentDir;
        _ls.currentDir = (basedir && ! fn.isChildOf(basedir))
                        ? basedir : fn;
        _tiler.loadDirsFiles(_ls.dirs, _ls.files);
        return currentDir;
    }

private:
    this(Geom g, Ls ls, Tiler tiler)
    {
        super(g);
        _ls        = ls;
        _tiler     = tiler;
        _scrollbar = new Scrollbar(new Geom(0, 0, 20, g.yl, From.RIGHT));
        addChildren(_tiler, _scrollbar);
    }
}
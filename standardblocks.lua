 TetrisStandard = {
    { --|
        pieces = {
            Point:new(0, 2),
            Point:new(0, 1),
            Point:new(0, 0),
            Point:new(0, -1)
        },
        center = {
            Point:new(0, 0)
        },
        dim = {
            xmax = 0, 
            xmin = 0, 
            ymax = 2, 
            ymin = -1
        }
    },
    { -- T
        pieces = {
            Point:new(0,1),
            Point:new(0,0),
            Point:new(-1,0),
            Point:new(1, 0)
        },
        center = {
            Point:new(0,0)
        },
        dim = {
            xmax = 1,
            xmin = -1,
            ymax = 1,
            ymin = 0
        }
    },
    { --S
        pieces = {
            Point:new(0, 1),
            Point:new(1, 1),
            Point:new(0, 0),
            Point:new(-1, 0)
        },
        center = {
            Point:new(0, 0)
        },
        dim = {
            xmax = 1,
            xmin = -1,
            ymax = 1,
            ymin = 0
        }
    },
    { --Z
        pieces = {
            Point:new(-1, 1),
            Point:new(0, 1),
            Point:new(0, 0),
            Point:new(1, 0)
        },
        center = {
            Point:new(0, 0)
        },
        dim = {
            xmax = 1,
            xmin = -1,
            ymax = 1, 
            ymin = 0
        }
    },
    { --J
        pieces = {
            Point:new(-1, 1),
            Point:new(-1, 0),
            Point:new(0, 0),
            Point:new(1, 0)
        },
        center = {
            Point:new(0, 0)
        },
        dim = {
            xmax = 1, 
            xmin = -1,
            ymax = 1,
            ymin = 0
        }
    },
    { --L
        pieces = {
            Point:new(-1, 0),
            Point:new(0, 0),
            Point:new(1, 0),
            Point:new(1, 1)
        }, 
        center = {
            Point:new(0, 0)
        }, 
        dim = {
            xmax = 1,
            xmin = -1,
            ymax = 1,
            ymin = 0
        }
    },
    { --O
        pieces = {
            Point:new(0, 0),
            Point:new(0, 1),
            Point:new(1, 1),
            Point:new(1, 0)
        }, 
        center = {
            Point:new(0, 0)
        },
        dim = {
            xmax = 1,
            xmin = 0,
            ymax = 1,
            ymin = 0
        }
    }
}
         
            
            
         
        
classdef Vision
    %VISION: Object to encapsulate all image processing functionality
    
    properties
        Environment;    % Environment object dependency
        Plotter;        % Plotter object dependency
        Camera;         % overhead webcam object
        BWThreshold;    % threshold with which binarize images to black/white when tracking
        AnchorSize;     % minimum size of visual tracking anchor in pixels used in denoising BW image
    end
    
    methods
        function obj = Vision(inputEnvironment, inputPlotter)
            %VISION Construct and configure a vision object
            
            obj.Environment = inputEnvironment;
            obj.Plotter = inputPlotter;
            obj = obj.StartCamera();
        end
        
        function obj = StartCamera(obj)
            %StartCamera: Clear image acquisition toolbox, startup
            %   environment camera, and automatically determine proper
            %   BWThreshold setting to track robots
            
            % configure camera
            imaqreset;
            obj.Camera = videoinput('winvideo', 1);
            triggerconfig(obj.Camera, 'manual');
            start(obj.Camera);
            
            % find and set BWThreshold
            obj.BWThreshold = obj.GetBWThreshold();
            
            % find and set AnchorSize
            obj.AnchorSize = obj.GetAnchorSize();
        end
        
        function obj = GetSnapshot(obj)
            %GetSnapshot: Takes and plots color image with environment camera
            
            colorImg = getsnapshot(obj.Camera);
            obj.Plotter = obj.Plotter.PlotColorImage(colorImg);
        end
        
        function bwImg = GetBWSnapshot(obj)
            %GetBWSnapshot: Takes and plots image with environment camera
            %   converted to black and white given BWThreshold and
            %   AnchorSize
            
            colorImg = getsnapshot(obj.Camera);
            bwImg = imbinarize(rgb2gray(colorImg), obj.BWThreshold);
            bwImg = bwareaopen(bwImg, obj.AnchorSize);
            
            obj.Plotter = obj.Plotter.PlotBWImage(bwImg);
        end
        
        function threshold = GetBWThreshold(obj)
            %FindBWThreshold: Determine optimal black/white cutoff
            %   threshold to properly deduce locations of robot visual anchors
            
            threshold = 0.7;
            %TODO: actually implement auto-set algorithm
        end
        
        function anchorSize = GetAnchorSize(obj)
           %GetAnchorSize: Determine optimal anchor size to properly deduce
           %    locations of robot visual anchors 
           
           anchorSize = 10;
           %TODO: actually implement auto-set algorithm
        end
    end
end


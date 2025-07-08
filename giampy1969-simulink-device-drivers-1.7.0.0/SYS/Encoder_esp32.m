classdef Encoder_esp32 < realtime.internal.SourceSampleTime ...
        & coder.ExternalDependency ...
        & matlab.system.mixin.Propagates ...
        & matlab.system.mixin.CustomIcon 
    %
    %Read the position of a quadrature encoder.
    %
    %
    
    % Copyright 2014 The MathWorks, Inc.
    %#codegen
    %#ok<*EMCA>
    
    properties (Nontunable)
        Encoder = 0
        PinA = 2
        PinB = 3
    end
    
    properties (Constant, Hidden)
        % Update the range of pins for ESP32
        AvailablePin = 0:39; % ESP32 GPIO range
        MaxNumEncoder = 2; % Adjust based on ESP32 hardware timer resources
    end

    
    methods
        % Constructor
        function obj = Encoder_arduino(varargin)
            coder.allowpcode('plain');
            
            % Support name-value pair arguments when constructing the object.
            setProperties(obj,nargin,varargin{:});
        end
        
        function set.PinA(obj,value)
            coder.extrinsic('sprintf') % Do not generate code for sprintf
            validateattributes(value,...
                {'numeric'},...
                {'real','nonnegative','integer','scalar'},...
                '', ...
                'PinA');
            assert(any(value == obj.AvailablePin), ...
                'Invalid value for Pin. Pin must be one of the following: %s', ...
                sprintf('%d ', obj.AvailablePin));
            obj.PinA = value;
        end
        
        function set.PinB(obj,value)
            coder.extrinsic('sprintf') % Do not generate code for sprintf
            validateattributes(value,...
                {'numeric'},...
                {'real','nonnegative','integer','scalar'},...
                '', ...
                'PinB');
            assert(any(value == obj.AvailablePin), ...
                'Invalid value for Pin. Pin must be one of the following: %s', ...
                sprintf('%d ', obj.AvailablePin));
            obj.PinB = value;
        end
        
        function set.Encoder(obj,value)
            validateattributes(value,...
                {'numeric'},...
                {'real','nonnegative','integer','scalar','>=',0,'<=',obj.MaxNumEncoder},...
                '', ...
                'Encoder');
            obj.Encoder = value;
        end
    end
    
    methods (Access=protected)
        function setupImpl(obj)
            if coder.target('Rtw')
                % Call: void enc_init(int enc, int pinA, int pinB)
                coder.cinclude('encoder_esp32.h');
                coder.ceval('enc_init', obj.Encoder, obj.PinA, obj.PinB);
            end
        end
        
        function y = stepImpl(obj)
            y = int32(0);
            if coder.target('Rtw')
                % Call: int enc_output(int enc)
                y = coder.ceval('enc_output', obj.Encoder);
            end
        end
        
        function releaseImpl(obj) %#ok<MANU>
        end
    end
    
    methods (Access=protected)
        %% Define output properties
        function num = getNumInputsImpl(~)
            num = 0;
        end
        
        function num = getNumOutputsImpl(~)
            num = 1;
        end
        
        function flag = isOutputSizeLockedImpl(~,~)
            flag = true;
        end
        
        function varargout = isOutputFixedSizeImpl(~,~)
            varargout{1} = true;
        end
        
        function flag = isOutputComplexityLockedImpl(~,~)
            flag = true;
        end
        
        function varargout = isOutputComplexImpl(~)
            varargout{1} = false;
        end
        
        function varargout = getOutputSizeImpl(~)
            varargout{1} = [1,1];
        end
        
        function varargout = getOutputDataTypeImpl(~)
            varargout{1} = 'int32';
        end
        
        function icon = getIconImpl(~)
            % Define a string as the icon for the System block in Simulink.
            icon = 'Encoder';
        end
    end
    
    methods (Static, Access=protected)
        function simMode = getSimulateUsingImpl(~)
            simMode = 'Interpreted execution';
        end
        
        function isVisible = showSimulateUsingImpl
            isVisible = false;
        end
    end
    
    methods (Static)
        function name = getDescriptiveName()
            name = 'Encoder';
        end
        
        function b = isSupportedContext(context)
            b = context.isCodeGenTarget('rtw');
        end
        
        function updateBuildInfo(buildInfo, context)
            if context.isCodeGenTarget('rtw')
                rootDir = fullfile(fileparts(mfilename('fullpath')), '..', 'src');
                buildInfo.addIncludePaths(rootDir);
                buildInfo.addIncludeFiles('encoder_esp32.h');
                buildInfo.addSourceFiles('encoder_esp32.cpp', rootDir);
            end
        end
    end
end

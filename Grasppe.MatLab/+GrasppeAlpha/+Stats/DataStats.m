classdef DataStats
  %UNIFORMITYSTATS Mean, Standard Deviation... etc.
  %   Detailed explanation goes here
  
  properties (Dependent, Transient)
    Data
    Mean
    Sigma
    SixSigma
    ReferenceMean
    ReferenceSigma
    Outliers
    OutlierIndex
    Samples
    
    UpperLimit
    LowerLimit
    PeakLimit
    Limits
  end
  
  properties (GetAccess=protected, SetAccess=immutable)
    data            = [];
    referenceMean   = [];
    referenceSigma  = [];
  end
  
  properties (Access=protected, Transient)
    mean            = [];
    sigma           = [];
    outlierIndex    = [];
  end
  
  methods
    function val = DataStats(data, mu, sigma)
      if isnumeric(data)
        val.data  = data;
      elseif isa(data, eval(NS.CLASS))
        val.data  = data.data;
      end
      
      if exist('mu', 'var'),  val.referenceMean   = mu; end
      if exist('sigma', 'var'), val.referenceSigma  = sigma; end
    end
    
    %% Immutable Properties
    function data = get.Data(val)
      data = val.data;
    end
    
    function referenceMean = get.ReferenceMean(val)
      referenceMean = val.referenceMean;
    end
    
    function referenceSigma = get.ReferenceSigma(val)
      referenceSigma = val.referenceSigma;
    end
    
    %% Stored Transient Properties
    function mu = get.Mean(val)
      if isempty(val.mean),
        val.mean = nanmean(val.Samples);
      end
      
      mu = val.mean;
    end
    
    function sigma = get.Sigma(val)
      if isempty(val.sigma)
        val.sigma = nanstd(val.Samples);
      end
      
      sigma = val.sigma;
    end
    
    function outlierIndex = get.OutlierIndex(val)
      if isempty(val.outlierIndex)
        data              = val.Data;
        
        mu                = val.ReferenceMean;
        if isempty(mu),     mu    = nanmean(data(:)); end
        
        sigma             = val.ReferenceSigma;
        if isempty(sigma),  sigma = nanstd(data(:)); end
        
        outliers          = abs(data - mu) > 3*sigma;
        val.outlierIndex  = outliers; %find(outliers);
      end
      outlierIndex = val.outlierIndex;
    end
    
    %% Computed Properties
    function sixSigma = get.SixSigma(val)
      sixSigma  =  6 * val.Sigma;
    end
    
    function limits = get.Limits(val)
      mu        = val.Mean;
      sigma     = val.Sigma;
      limits    = mu + sigma * [3 -3];
    end
    
    function limit = get.PeakLimit(val)
      mu        = val.Mean;
      sigma     = val.Sigma;
      limit     = mu + sigma*[3 -3];      
      Mu        = val.ReferenceMean;
      if isnumeric(Mu) && isscalar(Mu)
        delta   = abs(Mu - limit);
        idx     = 1+(delta(1)>delta(2));
        limit   = limit(idx);
      end
    end
    
    
    function limit = get.UpperLimit(val)
      mu        = val.Mean;
      sigma     = val.Sigma;
      limit     = mu + sigma * 3;
    end
    
    function limit = get.LowerLimit(val)
      mu        = val.Mean;
      sigma     = val.Sigma;
      limit     = mu - sigma * 3;
    end    
    
    
    function outliers = get.Outliers(val)
      outliers  = val.data(val.OutlierIndex);
    end
    
    function samples = get.Samples(val)
      samples   = val.data(~val.OutlierIndex);
    end
    
    %% Cat Overloads
    
    function val = horzcat(varargin)
      val = catData(@horzcat, varargin{:});
    end
    
    function val = vertcat(varargin)
      val = catData(@vertcat, varargin{:});
    end
    
    function val = cat(varargin)
      val = catData(@cat, varargin{:});
    end
    
    
    %% Constructors
    
    function B = setReference(A, mu, sigma)
      import(eval(NS.CLASS));
      
      if isnumeric(A)
        data  = A;
      elseif isa(A, eval(NS.CLASS))
        data  = A.data;
      end
      
      B = DataStats(data, mu, sigma);
    end
    
    function B = catData(fcn, varargin)
      import(eval(NS.CLASS));
      
      data    = cellfun(@(A) double(A.Data),varargin,'UniformOutput',false );
      catdata = fcn(data{:});
      
      mu      = cell2mat(cellfun(@(A) double(A.ReferenceMean),varargin,'UniformOutput',false ));
      sigma   = cell2mat(cellfun(@(A) double(A.ReferenceSigma),varargin,'UniformOutput',false ));
      
      mu      = unique(mu);
      sigma   = unique(sigma);
      
      if numel(mu)~=1 || numel(sigma)~=1
        mu    = [];
        sigma = [];
      end
      
      B       = DataStats(catdata, mu, sigma);
    end
    
  end
  
end


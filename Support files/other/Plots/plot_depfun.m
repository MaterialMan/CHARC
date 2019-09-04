function varargout = plot_depfun(foo,varargin)
% by Christopher Pedersen @ https://uk.mathworks.com/matlabcentral/fileexchange/46080-plot_depfun

%plot_depfun(foo,varargin)
%plots a tree of the dependencies of function foo
%ignores built-in function, any any function names given in varargin
%
%see also    : depfun, plot_subfun (file exchange ID 46070)
opt.ignore  = varargin;
opt.me      = which(foo);
if isempty(opt.me); error('this file could not be found'); end
opt.me      = sub_fileparts(opt.me);
opt         = sub_deps(opt);
opt.us      = sub_fileparts(opt.us);
opt.us.islocal = ismember(opt.us.fol,opt.me.fol);
sub_plot(opt);
if nargout;
    varargout{1} = opt;
end
end

function out = sub_fileparts(foos)
if iscell(foos)
    for i=1:numel(foos)
        if ~exist(foos{i},'file')
            disp(foos{i});
            error('this file does not exist');
        end
    end
end
fols = regexprep(foos,'[^/|\\]+$','');
%short name of each function, and the folder it occurs
short = regexp(foos,'[^/|\\]+$','match','once');
short = regexprep(short,'\..+','');
out.full  = foos;
out.fol   = fols;
out.short = short;
end
function opt = sub_deps(opt)
%find dependencies of opt.me
%uses recursive calls to depfun with -toponly
%culls builtin functions for speed
names = {opt.me.full}; %list of all files found (will grow)
done = false;          %which files have been examined
from = [];             %dependency - parent
to   = [];             %dependency - child
t = now;
while any(~done)
    for i=find(~done)
        if verLessThan('matlab','8.3');
            new = depfun(names{i},'-toponly','-quiet')';
            %remove any that are built in
            keep = cellfun('isempty',strfind(new,matlabroot));
        else
            new = matlab.codetools.requiredFilesAndProducts(names{i},'toponly');
            %built-in already removed
            keep = true(size(new));
        end
        %catch any strange return sizes from other os/versions
        if size(new,1)>1; new = new'; end
        %remove self
        keep(ismember(new,names{i})) = false;
        %remove ignored : full filename
        keep(ismember(new,opt.ignore)) = false;
        %remove ignored : short filename
        short = regexp(new,'[^/|\\]+$','match','once');
        keep(ismember(short,opt.ignore)) = false;
        %remove ignored : short filename no extension
        short = regexprep(short,'\..+','');
        keep(ismember(short,opt.ignore)) = false;
        %reduce the set of new
        new = new(keep);
                
        %add to list of names any new that are not already in it
        [~,~,I] = setxor(names,new);
        names = [names new(I)]; %#ok<AGROW>
        %rearrange I because apparently mac and pc do things differently
        if size(I,1)>1; I = I'; end
        
        %add to list of done
        done = [done false(size(I))]; %#ok<AGROW>
        done(i) = true;
        
        %new dependencies
        [~,newkid] = ismember(new,names);
        newdad = repmat(i,size(newkid));
        from = [from newdad]; %#ok<AGROW>
        to   = [to   newkid]; %#ok<AGROW>
        %report every 10 seconds
        if now-t>10;
            t = now;
            fprintf(1,'%d dependencies found so far',numel(names));
        end
    end
end
%sort names
[names,order] = sort(names);
%sort from/to references to match new names order
[~,rev] = sort(order);
from = rev(from);
to   = rev(to);
%export results
opt.us = names;
opt.from = from;
opt.to   = to;
end
function sub_plot(opt)
if isempty(opt.from); disp('this function has no dependencies'); return; end
cols = repmat('b',size(opt.us.short));
cols(~opt.us.islocal) = 'r';
plot_graph(opt.us.short,opt.from,opt.to,'-colour',cols);
end
%% DEVNOTES
%140329 added handling of functions with no dependencies
%150311 bugfix : was not ignoring function calls correctly if they didn't
%                have an extension.

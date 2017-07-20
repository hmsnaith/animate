disp('Global Attributes')
disp('New fields vs Maureen''s');
flds = fieldnames(g);
for i=1:length(flds)
  fld = flds{i};
  if isfield(gm,fld)
    if ~strcmp(g.(fld).Value,gm.(fld).Value)
      disp(['Maureen''s ' fld ': ' gm.(fld).Value]);
      disp(['New       ' fld ': ' g.(fld).Value]);
    end
  else
    disp(['No matching field for ' fld ': ' g.(fld).Value]);
  end
end
disp('Maureen''s fields vs New');
flds = fieldnames(gm);
for i=1:length(flds)
  fld = flds{i};
  if ~isfield(g,fld)
    disp(['No matching field for ' fld ': ' gm.(fld).Value]);
  end
end

disp('Variable Attributes')
disp('New fields vs Maureen''s');
flds = fieldnames(v);
for i=1:length(flds)
  fld = lower(flds{i}); fldm = fld;
  switch fld
    case 'doxy'
      fldm = 'doxm';
  end
  if isfield(v,upper(fld)), fld = upper(fld); end
  if isfield(vm,upper(fldm)), fldm = upper(fldm); end
  if isfield(vm,fldm)
    atts = fieldnames(v.(fld).Attr);
    for j= 1:length(atts)
      att = atts{j};
      if isnumeric(v.(fld).Attr.(att).Value)
        AttVal = [num2str(v.(fld).Attr.(att).Value) ' - as number'];
      else
        AttVal = v.(fld).Attr.(att).Value;
      end
      if isfield(vm.(fldm).Attr,att)
        if isnumeric(vm.(fldm).Attr.(att).Value)
          AttValm = [num2str(vm.(fldm).Attr.(att).Value) ' - as number'];
        else
          AttValm = vm.(fldm).Attr.(att).Value;
        end
        if ~strcmp(AttVal,AttValm)
          disp(['Maureen''s ' fldm ': ' att ': ' AttValm]);
          disp(['New       ' fld ': ' att ': ' AttVal]);
        end
      else
        disp(['No matching attribute ' att ' for variable ' fld ': ' AttVal]);
      end
    end
  else
    disp(['No matching variable for ' fld]);
  end
end

disp('Maureen''s fields vs New');
flds = fieldnames(vm);
for i=1:length(flds)
  fldm = lower(flds{i}); fld = fldm;
  switch fldm
    case 'doxm'
      fld = 'doxy';
  end
  if isfield(v,upper(fld)), fld = upper(fld); end
  if isfield(vm,upper(fldm)), fldm = upper(fldm); end
  if isfield(v,fld)
    if isfield(vm.(fldm),'Attr')
      atts = fieldnames(vm.(fldm).Attr);
      for j= 1:length(atts)
        att = atts{j};
        if ~isfield(v.(fld).Attr,att)
          if isnumeric(vm.(fldm).Attr.(att).Value)
            AttVal = [num2str(vm.(fldm).Attr.(att).Value) ' - as number'];
          else
            AttVal = vm.(fldm).Attr.(att).Value;
          end
          disp(['No matching attribute ' att ' for variable ' fldm ': ' AttVal]);
        end
      end
    else
      disp(['Maureen''s ' fldm ' has no Attributes']);
    end
  else
    disp(['No matching variable for ' fldm]);
  end
end

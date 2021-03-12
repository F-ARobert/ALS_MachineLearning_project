function [img] = create_3d_image(tiff_object)
%subimages = [512;512;3;74];
i = 1;
while 1
    subimage = tiff_object.read();
    subimages(:,:,:,i) = subimage(:,:,1:3);
    
    if (tiff_object.lastDirectory())
        break;
    end
    
    tiff_object.nextDirectory()
    i = i+1;
end
    
idx = [1 2 4 3];
img = permute(subimages,idx);

end
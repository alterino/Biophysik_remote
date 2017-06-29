classdef classOmeroWrapper < handle
    %written by
    %C.P.Richter
    %Division of Biophysics / Group J.Piehler
    %University of Osnabrueck
    
    %modified 17.10.2014
    
    properties
        Client
        Session
    end %properties
    
    methods
        %constructor
        function this = classOmeroWrapper
            this.Client = loadOmero('sfb-omero.biologie.Uni-Osnabrueck.DE', 4064);
            this.Client.enableKeepAlive(1);
        end %fun
        
        function login(this)
            this.Session = this.Client.createSession('Richter', 'Christian123');
        end %fun
        
        function dataset = create_dataset(~,name,description)
            dataset = omero.model.DatasetI;
            dataset.setName(omero.rtypes.rstring(name));
            dataset.setDescription(omero.rtypes.rstring(description));
        end %fun
        
        function link_dataset_to_project(this,dataset,projectId)
            link = omero.model.ProjectDatasetLinkI;
            link.setChild(dataset);
            link.setParent(omero.model.ProjectI(projectId, false));
            
            this.Session.getUpdateService().saveAndReturnObject(link);
        end %fun
        
        function create_image(this)
            try
                % Read the dimensions
                sizeX = 200;
                sizeY = 100;
                sizeZ = 1; % The number of z-sections.
                sizeT = 5; % The number of timepoints.
                sizeC = 2; % The number of channels.
                type = 'uint16';
                
                % Retrieve pixel type
                pixelsService = this.Session.getPixelsService();
                pixelTypes = toMatlabList(pixelsService.getAllEnumerations('omero.model.PixelsType'));
                pixelTypeValues = arrayfun(@(x) char(x.getValue().getValue()),...
                    pixelTypes, 'Unif', false);
                pixelType = pixelTypes(strcmp(pixelTypeValues, type));
                
                % Create a new image
                disp('Uploading new image onto the server');
                description = sprintf('Dimensions: %g x %g x %g x %g x %g',...
                    sizeX, sizeY, sizeZ, sizeC, sizeT);
                name = 'New image';
                idNew = pixelsService.createImage(sizeX, sizeY, sizeZ, sizeT,...
                    toJavaList(0:sizeC-1, 'java.lang.Integer'), pixelType, name, description);
                
                %load the image.
                disp('Checking the created image');
                imageNew = getImages(this.Session, idNew.getValue());
                assert(~isempty(imageNew), 'OMERO:CreateImage', 'Image Id not valid');
                
                % load the dataset
                fprintf(1, 'Reading dataset: %g\n', datasetId);
                dataset = getDatasets(session, datasetId, false);
                assert(~isempty(dataset), 'OMERO:CreateImage', 'Dataset Id not valid');
                
                % Link the new image to the dataset
                fprintf(1, 'Linking image %g to dataset %g\n', idNew.getValue(), datasetId);
                link = omero.model.DatasetImageLinkI;
                link.setChild(omero.model.ImageI(idNew, false));
                link.setParent(omero.model.DatasetI(dataset.getId().getValue(), false));
                session.getUpdateService().saveAndReturnObject(link);
                
                % Copy the data.
                fprintf(1, 'Copying data to image %g\n', idNew.getValue());
                pixels = imageNew.getPrimaryPixels();
                store = this.Session.createRawPixelsStore();
                store.setPixelsId(pixels.getId().getValue(), false);
                
                % Upload template for every plane in the image
                for z = 1 : sizeZ,
                    for c = 1:sizeC
                        for t = 1: sizeT,
                            index = sub2ind([sizeZ sizeC sizeT], z, c, t);
                            store.setPlane(byteArray, z - 1, c - 1, t - 1);
                        end
                    end
                end
                store.save(); %save the data
                store.close(); %close
            catch err
                client.closeSession();
                throw(err);
            end
            % Close the session
            client.closeSession();
        end %fun
    end %methods
end %classdef

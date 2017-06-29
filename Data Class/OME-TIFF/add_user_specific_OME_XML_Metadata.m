function metadata = add_user_specific_OME_XML_Metadata(metadata)
experimenterIndex = 0;
experimenterGroupIndex = 0;
leaderIndex = 0;
setExperimenterID(metadata,'Experimenter:0',experimenterIndex) 
setExperimenterGroupID(metadata,'ExperimenterGroup:0',experimenterIndex) 

%%
setExperimenterInstitution(metadata,'University of Osnabrueck',experimenterIndex)
setExperimenterGroupName(metadata,'Biophysics',experimenterGroupIndex)
setExperimenterGroupLeader(metadata,'Jacob Piehler',experimenterGroupIndex,leaderIndex)
setExperimenterFirstName(metadata,'Christian',experimenterIndex)
setExperimenterMiddleName(metadata,'Paolo',experimenterIndex)
setExperimenterLastName(metadata,'Richter',experimenterIndex)
setExperimenterEmail(metadata,'Christian.Richter@Biologie.Uni-Osnabrueck.de',experimenterIndex)
end %fun
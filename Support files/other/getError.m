function error = getError(error_to_check,individual)
switch(error_to_check)    
    case 'train'
        error = [individual.train_error];
    case 'val'
        error = [individual.val_error];
    case'test'
        error = [individual.test_error];
    case 'train&val'
        error = [individual.train_error] + [individual.val_error];
    case 'val&test'
        error = [individual.val_error] + [individual.test_error];
    case 'train&val&test'
        error = [individual.train_error] +[individual.val_error] +[individual.test_error];        
end
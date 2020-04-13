classdef DistributionGenerator
    %DISTRIBUTIONGENERATOR Used to generate distributions for testing
    
    properties
        Prop
    end
    
    methods(Static)
        function z = squared_exponential_four_corners(hilgpc_data)
            % Generate a squared exponential four-corner function over x
            %
            % hilgpc_data : HILGPC_Data object with meshgrid points
            
            x = hilgpc_data.TestPoints;
            
            centers = [100,100; 100,200; 600,100; 600,200];
            len = 50;
            s2 = 5;
            z = zeros(size(x,1), 1);
            
            for i = 1:size(centers,1)
                
                % add squared kerned based at each center point
                center = centers(i,:);
                
                deltaX2 = (x(:,1) - center(:,1)).^2 + (x(:,2) - center(:,2)).^2;
                power = -deltaX2 ./ (2 * len * len);
                term = s2 .* exp(power);
                z = z + term;
                
            end
            
        end
        
        function Visualize(hilgpc_data, z)
            % Visualize generated function with heatmap
            %
            % hilgpc_data : HILGPC_Data object with meshgrid points
            % z : function values generated by generated function
            
            figure;
            meshX = hilgpc_data.TestMeshX;
            meshY = hilgpc_data.TestMeshY;
            mesh(meshX, meshY, reshape(z, size(meshX, 1), []), 'FaceColor', 'interp');
            colormap('jet');
            view(2);
            daspect([1,1,1]);
            
        end
        
        function SaveGroundTruth(filename, hilgpc_data, z)
            % Save ground truth function for use in computing loss function
            %
            % filename : where to save ground truth to
            % hilgpc_data : HILGPC_Data object with meshgrid points
            % z : function values generated by generated function
            
            dist = cat(2, hilgpc_data.TestPoints, z);
            dist(1, 4) = 1;
            
            figure;
            scatter(dist(:,1), dist(:,2), 50, dist(:,3), 'filled')
            title('Ground Truth');
            colorbar;
            
            
            file = fopen(filename, 'w');
            fprintf(file, "X,Y,Means,Confidence\n");
            fclose(file);
            
            dlmwrite(filename, dist, '-append');
            
        end
        
        function SaveHifi(filename, hilgpc_data, z, proportion)
            % Save high fidelity grid for use in training hyperparams
            %
            % filename : where to save hifi to
            % hilgpc_data : HILGPC_Data object with meshgrid points
            % z : function values generated by generated function
            
            dist = cat(2, hilgpc_data.TestPoints, z);
            
            % take proportion * n random samples for lofi set
            sample_idx = randsample(1:size(dist,1), round(proportion * size(dist, 1)))';
            hifi = dist(sample_idx, :);
            
            % preview what's being saved
            figure;
            scatter(hifi(:,1), hifi(:,2), 50, hifi(:,3), 'filled')
            title('Hifi - No Noise');
            colorbar;
                        
            save
            file = fopen(filename, 'w');
            fprintf(file, "X,Y,Means\n");
            fclose(file);
            
            dlmwrite(filename, hifi, '-append');
            
        end
        
        function SaveLofi(filename, hilgpc_data, z, proportion, sn)
            % Save low fidelity grid for use in training hyperparams
            %
            % Take a random subset of high fidelity training points, add
            % Gaussian noise, and save for training
            %
            % filename : where to save lofi to
            % hilgpc_data : HILGPC_Data object with meshgrid points
            % z : function values generated by generated function
            % proportion : proportion of hifi points to keep in lofi
            % sn : sample noise to add to lofi points
            
            dist = cat(2, hilgpc_data.TestPoints, z);
            
            % take proportion * n random samples for lofi set
            sample_idx = randsample(1:size(dist,1), round(proportion * size(dist, 1)))';
            samples = dist(sample_idx, :);
            
            % add gaussian noise to lofi set
            noise = normrnd(0, sn, size(samples, 1), 1);            
            lofi = [samples(:, 1:2), samples(:, 3) + noise];
            
            % preview what's being saved
            figure;
            scatter(samples(:,1), samples(:,2), 50, samples(:,3), 'filled')
            title('Lofi - No Noise');
            colorbar;
            figure;
            scatter(lofi(:,1), lofi(:,2), 50, lofi(:,3), 'filled')
            title('Lofi - Noise Added');
            colorbar;
                        
            % save
            file = fopen(filename, 'w');
            fprintf(file, "X,Y,Means\n");
            fclose(file);
            
            dlmwrite(filename, lofi, '-append');
            
        end
    end
end

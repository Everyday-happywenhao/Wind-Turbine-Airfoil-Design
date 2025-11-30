aerofoil_files = {'C:\Users\messiwhx\Desktop\aerofoil\clcd_Naca0015.csv', 'C:\Users\messiwhx\Desktop\aerofoil\clcd_Naca0021.csv', 'C:\Users\messiwhx\Desktop\aerofoil\xf-naca0010-il-1000000.csv ','C:\Users\messiwhx\Desktop\aerofoil\xf-naca0012h-sa-1000000.csv', 'C:\Users\messiwhx\Desktop\aerofoil\xf-naca0018-il-1000000.csv'};
num_profiles = length(aerofoil_files);
% 初始化变量存储最大功率系数及对应的翼型
max_CP_overall = -Inf; % Initialize the overall max CP
best_TSR_overall = NaN; % Initialize the overall best TSR
best_aerofoil = ''; % Initialize the best aerofoil

% 定义参数范围
nblades_range = 2:5;
height_range = 10:2:30;
chord_range = 0:0.1:2;
U_range = 25:5:56;

% 循环遍历每个翼型文件
for i = 1:num_profiles
    for nblades = nblades_range
        for height = height_range
            for chord = chord_range
                for U = U_range
                    %% Creating the turbine object
                    myTurbine = VAWT.DMST(0.157, 2, nblades, aerofoil_files{i});

                    %% Changing parameters
                    myTurbine.set('solidity', 0.157);
                    myTurbine.set('nblades', nblades);
                    myTurbine.set('height', height);
                    myTurbine.set('chord', chord);
                    myTurbine.set('wake', 0);
                    myTurbine.set('U', U);

                    %% TSR as a vector
                    TSR_vector = 1:1:10;
                    myTurbine.set('TSR', TSR_vector);

                    %% Pitch
                    myTurbine.set('pitch', 0);

                    %% Running the solver
                    myTurbine.solve;

                    %% Obtaining the output data
                    outStruct = myTurbine.solution;

                    % Finding the maximum CP for the current configuration
                    CP_values = arrayfun(@(s) s.power.CP, outStruct);
                    [max_CP, idx_max] = max(CP_values);
                    best_TSR = TSR_vector(idx_max);

                    % Check if this is the overall maximum CP
                    if max_CP > max_CP_overall
                        max_CP_overall = max_CP;
                        best_TSR_overall = best_TSR;
                        best_aerofoil = aerofoil_files{i};
                        best_nblades = nblades;
                        best_height = height;
                        best_chord = chord;
                        best_U = U;
                    end
                end
            end
        end
    end
end

% Display the overall best results
fprintf('Overall, the maximum CP is %.4f for aerofoil %s at TSR = %d with nblades = %d, height = %.2f, chord = %.2f, and U = %.2f\n', ...
    max_CP_overall, best_aerofoil, best_TSR_overall, best_nblades, best_height, best_chord, best_U);


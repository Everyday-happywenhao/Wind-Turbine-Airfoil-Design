# Aerodynamic Performance Study of Straight-Blade Vertical Axis Wind Turbine Based on Adversarial Neural Network

## Project Overview
This project addresses the aerodynamic performance optimization of straight-blade vertical axis wind turbines by proposing an airfoil generation and optimization method based on Bézier-Generative Adversarial Networks. Through deep learning technology, geometric features are extracted from the UIUC airfoil database, combined with Bézier parameterization to generate new airfoil libraries, with aerodynamic optimization targeting maximum power coefficient.

## Design Parameters
- **Rated Power**: 5kW
- **Cut-in Wind Speed**: 3.5m/s
- **Rated Wind Speed**: 11m/s
- **Cut-out Wind Speed**: 25m/s
- **Power Coefficient**: >0.3
- **Rotor Radius**: 2.5m

## Technical Approach

### 1. Bézier-Generative Adversarial Network Construction
Developed a Bézier-Generative Adversarial Network using Python environment with TensorFlow 1.14 library. Based on the information-maximizing generative adversarial network framework, a Bézier layer was incorporated into the generator to control the curvature variations between generated airfoil coordinate points.

**Development Platform**: Python  
**Required Libraries**:
- tensorflow<2.0.0
- pyDOE
- sklearn
- numpy
- matplotlib
- autograd

**Folder**: `Development_of_a_Novel_Airfoil_Database`

### 2. Airfoil Generation and Screening
Learned geometric features from the UIUC airfoil database, extracted latent encodings and noise encodings, and combined them with Bézier parameterization techniques to generate new airfoil libraries. By setting screening criteria of airfoil thickness between 12%-15%, 3,972 qualified airfoils were selected from the originally generated 10,000 airfoils.

**Development Platform**: MATLAB  
**Folder**: `Establishing_an_Experimental_Environment`

### 3. Aerodynamic Performance Calculation
Established a four-dimensional parametric mapping relationship between phase angle, resultant wind speed, Reynolds number, and angle of attack. Employed XFOIL software to calculate lift and drag coefficients under dynamic Reynolds numbers, utilizing Viterna extrapolation method and cubic spline interpolation to compute coefficients for both stalled and unstalled attack angles.

**Development Platform**: MATLAB  
**Folder**: `Establishing_an_Experimental_Environment`

### 4. Double-Multiple Streamtube Model Optimization
Defined optimization constraints with wind speed of 11m/s, 3 blades, tip-speed ratio of 2.5, and solidity of 0.3, targeting maximum power coefficient as the optimization objective. Evaluated aerodynamic performance of generated airfoils using the double-multiple streamtube model.

**Development Platform**: MATLAB  
**Folder**: `Select_the_optimal_airfoil`

## Key Achievements

### Optimal Airfoil Performance
- **Optimal Airfoil Number**: Airfoil #3
- **Maximum Camber**: 7.0% (at 64.6% chord position)
- **Maximum Thickness**: 13.0% (at 46.4% chord position)
- **Power Coefficient**: 0.393
- **Actual Power Output**: 5036W (exceeding design power of 5000W)

### Performance Improvement Comparison
Compared to most commercial vertical axis wind turbines with power coefficients ranging from 0.28 to 0.32, this device achieves a performance improvement of 18.5% to 28.7%.



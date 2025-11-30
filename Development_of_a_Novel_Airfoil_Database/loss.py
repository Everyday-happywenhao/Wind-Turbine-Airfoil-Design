import argparse
import numpy as np
import os
import matplotlib.pyplot as plt

from gan_new import GAN
from mmd import ci_mmd
from consistency import ci_cons

import sys

sys.path.append('E:\\jwh_gan\\gan\\bezier-gan-master')
from shape_plot import plot_samples, plot_grid
from utils import ElapsedTimer, train_test_split


def save_coordinates(airfoils, directory):
    """
    Save the coordinates of the generated airfoils to text files.
    """
    create_dir(directory)
    for i, airfoil in enumerate(airfoils):
        coords_fname = '{}/airfoil_{}.txt'.format(directory, i)
        with open(coords_fname, 'w') as f:
            for x, y in airfoil:
                f.write(f"{x} {y}\n")


def create_dir(directory):
    """
    Create a directory if it does not exist.
    """
    if not os.path.exists(directory):
        os.makedirs(directory)


def validate_synthesized_data(data, latent_dim):
    """
    Validate the synthesized data to ensure it is correct and iterable.
    """
    if not isinstance(data, np.ndarray):
        raise ValueError(f"Expected synthesized data to be a numpy array, but got {type(data)}")
    if len(data.shape) != 2 or data.shape[1] != latent_dim:
        raise ValueError(f"Expected synthesized data to have shape (n_samples, {latent_dim}), but got {data.shape}")


if __name__ == "__main__":

    model_id = 1
    latent_dim = 3
    noise_dim = 10
    mode = 'train'
    save_interval = 500
    bezier_degree = 31
    train_steps = 10000
    batch_size = 32
    symm_axis = None
    bounds = (0., 1.)

    # Read dataset
    data_fname = '../data/airfoil_interp.npy'
    X = np.load(data_fname)

    print('Plotting training samples ...')
    samples = X[np.random.choice(range(X.shape[0]), size=36)]
    plot_samples(None, samples, scale=1.0, scatter=False, symm_axis=symm_axis, lw=1.2, alpha=.7, c='k',
                 fname='samples')

    # Split training and test data
    X_train, X_test = train_test_split(X, split=0.8)

    # Train
    directory = './trained_gan_loss/{}_{}'.format(latent_dim, noise_dim)
    if model_id is not None:
        directory += '/{}'.format(model_id)

    # Ensure the directory exists before proceeding
    create_dir(directory)

    model = GAN(latent_dim, noise_dim, X_train.shape[1], bezier_degree, bounds)
    if mode == 'train':
        timer = ElapsedTimer()

        # 调用训练方法并获取损失数据
        dis_losses, gen_losses = model.train(
            X_train,
            batch_size=batch_size,
            train_steps=train_steps,
            save_interval=save_interval,
            directory=directory
        )

        elapsed_time = timer.elapsed_time()
        runtime_mesg = 'Wall clock time for training: %s' % elapsed_time
        print(runtime_mesg)

        # Ensure the directory exists before saving runtime.txt
        create_dir(directory)
        runtime_file = open('{}/runtime.txt'.format(directory), 'w')
        runtime_file.write('%s\n' % runtime_mesg)
        runtime_file.close()

        # 绘制训练损失曲线
        plt.plot(range(1, train_steps + 1), dis_losses, label='Discriminator Loss')
        plt.plot(range(1, train_steps + 1), gen_losses, label='Generator Loss')
        plt.xlabel('Epoch')
        plt.ylabel('Loss')
        plt.title('Training Loss vs. Epoch')
        plt.legend()
        plt.show()

    else:
        model.restore(directory=directory)

    print('Plotting synthesized shapes ...')
    points_per_axis = 5  # 生成翼型个数为 n**2个 eg: Generate 10000

    # Generate synthesized airfoils and validate the output
    synthesized_airfoils = model.synthesize(np.random.rand(points_per_axis ** 2, latent_dim))
    validate_synthesized_data(synthesized_airfoils, latent_dim)

    plot_grid(points_per_axis, gen_func=model.synthesize, d=latent_dim, bounds=bounds, scale=1.0, scatter=False,
              symm_axis=symm_axis, alpha=.7, lw=1.2, c='k', fname='{}/synthesized'.format(directory))

    def synthesize_noise(noise):
        return model.synthesize(0.5 * np.ones((points_per_axis ** 2, latent_dim)), noise)

    synthesized_noise_airfoils = synthesize_noise(np.random.rand(points_per_axis**2, noise_dim))
    plot_grid(points_per_axis, gen_func=synthesize_noise, d=noise_dim, bounds=(-1., 1.), scale=1.0, scatter=False, symm_axis=symm_axis, alpha=.7, lw=1.2, c='k', fname='{}/synthesized_noise'.format(directory))

    n_runs = 10

    mmd_mean, mmd_err = ci_mmd(n_runs, model.synthesize, X_test)
    cons_mean, cons_err = ci_cons(n_runs, model.synthesize, latent_dim, bounds)

    results_mesg_1 = 'Maximum mean discrepancy: %.4f +/- %.4f' % (mmd_mean, mmd_err)
    results_mesg_2 = 'Consistency: %.3f +/- %.3f' % (cons_mean, cons_err)

    results_file = open('{}/results.txt'.format(directory), 'w')

    print(results_mesg_1)
    results_file.write('%s\n' % results_mesg_1)
    print(results_mesg_2)
    results_file.write('%s\n' % results_mesg_2)

    results_file.close()

    # Save the coordinates of the synthesized airfoils
    save_coordinates(synthesized_airfoils, '{}/synthesized_coords'.format(directory))
    save_coordinates(synthesized_noise_airfoils, '{}/synthesized_noise_coords'.format(directory))
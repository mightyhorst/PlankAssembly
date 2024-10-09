# Copyright (c) Manycore Tech Inc. and its affiliates. All Rights Reserved
"""
render visible vectorized svgs
"""
import argparse
import json
import os

import numpy as np
import shapely

from data_utils import *


def filter_hidden_lines(lines, line_types):
    print(f"🔍 Filtering hidden lines...")
    visible_lines = [line for line, line_type in zip(lines, line_types) if line_type == 0]
    line_types = [0, ] * len(visible_lines)
    print(f"👁️ Retained {len(visible_lines)} visible lines.")
    return visible_lines, line_types
    

def merge_degenerated_lines(lines):
    print(f"🛠️ Merging degenerated lines...")
    while True:
        endpoints = shapely.multipoints(np.concatenate([np.array(line.coords) for line in lines]))
        endpoints = shapely.get_parts(shapely.extract_unique_points(endpoints)).tolist()
        
        tree = shapely.STRtree(endpoints)
        line_indices, point_indices = tree.query(lines, predicate='touches')

        unique_point_indices, counts = np.unique(point_indices, return_counts=True)

        if np.all(counts != 2):
            break

        # collinear
        done = True
        for point_index in unique_point_indices[counts == 2]:
            i, j = line_indices[point_indices == point_index]
            
            if lines[i] is None or lines[j] is None:
                done = False

            line_i, line_j = lines[i], lines[j]

            # find collinear case and merge
            coords = shapely.get_coordinates([line_i, line_j])

            if len(np.unique(coords[:, 0])) == 1 or len(np.unique(coords[:, 1])) == 1:
                merged_line = shapely.multilinestrings([line_i, line_j])
                bounds = shapely.bounds(merged_line)
                bounds = np.array(bounds).reshape(2, 2)
                line = shapely.linestrings(*bounds.T)

                # remove merged lines
                lines[i] = None
                lines[j] = None
                lines.append(line)

        lines = [line for line in lines if line is not None]

        if done:
            break

    print(f"✅ Finished merging lines.")
    return lines


def post_process(lines, line_types):
    print(f"🔧 Starting post-processing...")

    lines, line_types = filter_hidden_lines(lines, line_types)
    lines, line_types = split_lines_on_crossing_points(lines, line_types)
    print(f"✂️ Split lines at crossing points.")
    
    lines, line_types = split_lines_on_endpoints(lines, line_types)
    print(f"🖍️ Split lines at endpoints.")
    
    lines, line_types = remove_overlapping_lines(lines, line_types)
    print(f"🧹 Removed overlapping lines.")
    
    lines = merge_degenerated_lines(lines)
    
    print(f"✅ Post-processing completed.")
    return lines, line_types


def render_three_views(name):
    try:
        print(f"📄 Processing model {name}...")

        with open(os.path.join(args.root, "model", f"{name}.json"), "r") as f:
            annos = json.loads(f.read())
        print(f"📂 Loaded JSON for {name}.")

        shape = build(annos['planks'])
        print(f"🛠️ Built shape for {name}.")

        for view in VPS:
            print(f"📐 Projecting {view} view for {name}...")
            
            lines, line_types = project(shape, view, args.decimals)

            lines, line_types = post_process(lines, line_types)

            render_svg(lines, line_types, view, name, args)
            print(f"🎨 SVG rendered for {name} in {view} view.")

    except Exception as re:
        print(f"❌ {name} failed, due to: {re}")


def main(args):
    print(f"🚀 Starting the rendering process with root directory: {args.root}...")
    info_files = parse_splits_list([
        os.path.join(args.root, 'splits', 'train.txt'),
        os.path.join(args.root, 'splits', 'valid.txt'),
        os.path.join(args.root, 'splits', 'test.txt')])

    names = [info_file.split('.')[0] for info_file in info_files]

    # Sequential processing (single-threaded)
    for name in names:
        render_three_views(name)

    print(f"🏁 Rendering process completed!")


if __name__ == '__main__':
    parser = argparse.ArgumentParser()
    parser.add_argument('--root', metavar="DIR", default="data",
                        help='dataset source root.')
    parser.add_argument('--data_type', type=str, default="visible",
                        help='data type.')
    parser.add_argument('--name', type=str, default="",
                        help='data name.')
    parser.add_argument('--line_width', type=str, default=0.5,
                        help='svg line width.')
    parser.add_argument('--decimals', type=int, default=3,
                        help='number of decimals.')
    args = parser.parse_args()

    os.makedirs(os.path.join(args.root, 'data', args.data_type, 'svgs'), exist_ok=True)

    if args.name:
        render_three_views(args.name)
    else:
        main(args)

//
//  NeonGradientProgressBarViewStyle.swift
//  NeonGradientProgressBar
//
//  Created by Felix Mau on 02.02.22.
//  Copyright © 2022 Felix Mau. All rights reserved.
//

import SwiftUI

// Workaround to fix `xcodebuild` errors when running `pod lib lint`, like e.g.:
//
// - `xcodebuild`: error: cannot find type 'Color' in scope
// - `xcodebuild`: error: cannot find type 'View' in scope
//
// > This failure occurs because builds with a deployment target earlier than iOS 11 will also build for the armv7 architecture,
// > and there is no armv7 swiftmodule for SwiftUI in the iOS SDK because the OS version in which it was first introduced (iOS 13)
// > does not support armv7 anymore.
//
// Source: https://stackoverflow.com/a/61954608
#if arch(arm64) || arch(x86_64)
    /// A `ProgressViewStyle` showing a gradient.
    ///
    /// - Note: Requires **iOS 15**, due to the view-modifier `mask(alignment:_:)`.
    @available(iOS 15.0, *)
    public struct NeonGradientProgressBarViewStyle: ProgressViewStyle {

        // MARK: - Config

        public enum Config {
            public static let defaultBackgroundColor = Color(UIColor.NeonGradientProgressBar.backgroundColor)
            public static let defaultGradientColors = UIColor.NeonGradientProgressBar.gradientColors.map(Color.init)
            public static let defaultCornerRadius: Double = 2
        }

        // MARK: - Public properties

        let backgroundColor: Color
        let gradientColors: [Color]
        let cornerRadius: Double

        // MARK: - Public methods

        public func makeBody(configuration: Configuration) -> some View {
            GeometryReader { proxy in
                ZStack {
                    RoundedRectangle(cornerRadius: cornerRadius)
                        .fill(backgroundColor)

                    LinearGradient(colors: gradientColors, startPoint: .leading, endPoint: .trailing)
                        .mask(alignment: .leading) {
                            RoundedRectangle(cornerRadius: cornerRadius)
                                .frame(width: (configuration.fractionCompleted ?? 0) * proxy.size.width)
                        }
                }
            }
        }
    }

    // MARK: - Helper

    @available(iOS 15.0, *)
    public extension ProgressViewStyle where Self == NeonGradientProgressBarViewStyle {
        /// Syntactic sugar for returning an instance of the `NeonGradientProgressBarViewStyle`
        /// with the **default parameters**.
        static var NeonGradientProgressBar: Self {
            NeonGradientProgressBar()
        }

        /// Syntactic sugar for returning an instance of the `NeonGradientProgressBarViewStyle`.
        ///
        /// - Parameters:
        ///  - backgroundColor: The background-color shown behind the gradient (clipped by a possible `cornerRadius`).
        ///  - gradientColors: The colors used for the gradient.
        ///  - cornerRadius: The corner-radius used on the background and the progress bar.
        static func NeonGradientProgressBar(backgroundColor: Color = NeonGradientProgressBarViewStyle.Config.defaultBackgroundColor,
                                        gradientColors: [Color] = NeonGradientProgressBarViewStyle.Config.defaultGradientColors,
                                        cornerRadius: Double = NeonGradientProgressBarViewStyle.Config.defaultCornerRadius) -> Self {
            NeonGradientProgressBarViewStyle(backgroundColor: backgroundColor,
                                         gradientColors: gradientColors,
                                         cornerRadius: cornerRadius)
        }
    }

#endif

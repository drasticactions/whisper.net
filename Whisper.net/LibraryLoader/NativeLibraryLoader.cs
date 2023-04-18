// Licensed under the MIT license: https://opensource.org/licenses/MIT

using System;
using System.IO;
using System.Runtime.InteropServices;
using Whisper.net.Native;

namespace Whisper.net.LibraryLoader;

public static class NativeLibraryLoader
{
    private static ILibraryLoader? defaultLibraryLoader = null;

    /// <summary>
    /// Sets the library loader used to load the native libraries. Overwrite this only if you want some custom loading.
    /// </summary>
    /// <param name="libraryLoader">The library loader to be used.</param>
    /// <remarks>
    /// It needs to be set before the first <seealso cref="WhisperFactory"/> is created, otherwise it won't have any effect.
    /// </remarks>
    public static void SetLibraryLoader(ILibraryLoader libraryLoader)
    {
        defaultLibraryLoader = libraryLoader;
    }

    internal static LoadResult LoadNativeLibrary()
    {
        var architecture = RuntimeInformation.OSArchitecture.ToString().ToLowerInvariant();

#if MACOS || MACCATALYST
        return LoadNativeLibrary("osx", architecture, "dylib");
#elif WINDOWS
        return LoadNativeLibrary("win", architecture, "dll");
#endif
        return LoadNativeLibraryStandard();
    }

    internal static LoadResult LoadNativeLibrary(string platform, string architecture, string extension)
    {
        var assemblySearchPath = new[]
        {
            AppDomain.CurrentDomain.RelativeSearchPath,
            Path.GetDirectoryName(typeof(NativeMethods).Assembly.Location),
            Path.GetDirectoryName(Environment.GetCommandLineArgs()[0])
        }.Where(it => !string.IsNullOrEmpty(it)).FirstOrDefault();

        var path = Path.Combine(assemblySearchPath, "runtimes", $"{platform}-{architecture}", $"whisper.{extension}");
        
        if (defaultLibraryLoader != null)
        {
            return defaultLibraryLoader.OpenLibrary(path);
        }

        if (!File.Exists(path))
        {
            throw new FileNotFoundException($"Native Library not found in path {path}. Probably it is not supported yet.");
        }

        ILibraryLoader libraryLoader = platform switch
        {
            "win" => new WindowsLibraryLoader(),
            "osx" => new MacOsLibraryLoader(),
            "linux" => new LinuxLibraryLoader(),
            _ => throw new PlatformNotSupportedException($"Currently {platform} platform is not supported")
        };

        var result = libraryLoader.OpenLibrary(path);
        return result;
    }

    internal static LoadResult LoadNativeLibraryStandard()
    {
        var architecture = RuntimeInformation.OSArchitecture switch
        {
            Architecture.X64 => "x64",
            Architecture.X86 => "x86",
            Architecture.Arm => "arm",
            Architecture.Arm64 => "arm64",
            _ => throw new PlatformNotSupportedException($"Unsupported OS platform, architecture: {RuntimeInformation.OSArchitecture}")
        };

        var (platform, extension) = Environment.OSVersion.Platform switch
        {
            _ when RuntimeInformation.IsOSPlatform(OSPlatform.Windows) => ("win", "dll"),
            _ when RuntimeInformation.IsOSPlatform(OSPlatform.Linux) => ("linux", "so"),
            _ when RuntimeInformation.IsOSPlatform(OSPlatform.OSX) => ("osx", "dylib"),
            _ => throw new PlatformNotSupportedException($"Unsupported OS platform, architecture: {RuntimeInformation.OSArchitecture}")
        };

        return LoadNativeLibrary(platform, architecture, extension);
    }
}

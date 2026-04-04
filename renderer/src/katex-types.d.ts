import type MarkdownIt from 'markdown-it';
import Katex from "katex"

export interface MathDelimiter {
    /**
     * Opening delimiter string
     */
    readonly left: string;
    
    /**
     * Closing delimiter string
     */
    readonly right: string;
    
    /**
     * Whether this delimiter represents a display (block) math expression
     */
    readonly display: boolean;
}

export interface MarkdownKatexOptions {
    /**
     * Enable rendering of bare `\begin` `\end` blocks without `$$` delimiters.
     */
    readonly enableBareBlocks?: boolean;

    /**
     * Enable rendering of `$$` match blocks inside of html elements.
     */
    readonly enableMathBlockInHtml?: boolean;

    /**
     * Enable rendering of inline match of html elements.
     */
    readonly enableMathInlineInHtml?: boolean;

    /**
     * Enable rendering of of fenced math code blocks:
     * 
     * ~~~md
     * ```math
     * \pi
     * ```
     * ~~~
     */
    readonly enableFencedBlocks?: boolean;

    /**
     * Controls if an exception is thrown on katex errors.
     */
    readonly throwOnError?: boolean;

    /**
     * Support for custom katex instance for extension such as mhchem 
     */
    katex?: typeof Katex
    
    /**
     * Custom math delimiters. If not provided, defaults to:
     * - Inline: $...$, \(...\)
     * - Display: $$...$$, \[...\]
     */
    delimiters?: MathDelimiter[];
}

export default function (md: MarkdownIt, options?: MarkdownKatexOptions): MarkdownIt;

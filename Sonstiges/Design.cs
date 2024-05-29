/* 
C# Source File
======================================================================
Created with: 	SAPIEN Technologies, Inc., PowerShell Studio 2022 v5.8.197
Created on:   	24.05.2024 09:17
Created by:   	clias12131
Organization: 	
Filename:     	Design.cs
======================================================================  
Comments: 

*/
using System;
using System.Drawing;
using System.Windows.Forms;

namespace CustomControls
{
    public class RoundedButton : Button
    {
        public RoundedButton()
        {
            // Runde Ecken festlegen
            this.Region = new Region(new Rectangle(0, 0, this.Width, this.Height));
        }

        protected override void OnPaint(PaintEventArgs e)
        {
            base.OnPaint(e);
            // Hintergrundfarbe und Ränder für den Button festlegen
            Graphics graphics = e.Graphics;
            Rectangle rectangle = new Rectangle(0, 0, this.Width, this.Height);
            Pen pen = new Pen(Color.Black, 1);
            graphics.DrawRectangle(pen, rectangle);
            SolidBrush brush = new SolidBrush(this.BackColor);
            graphics.FillRectangle(brush, rectangle);
        }
    }
}

